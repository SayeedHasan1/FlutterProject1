import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluttertest23/extentions/list/filter.dart';
import 'package:fluttertest23/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class NoteService {
  Database? _db;
  DatabaseUser? _user;

  List<DatabaseNote> _notes = [];
  static final NoteService _shared = NoteService._sharedInstances();
  NoteService._sharedInstances() {
    _noteStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _noteStreamController.sink.add(_notes);
      },
    );
  }

  factory NoteService() => _shared;

  late final StreamController<List<DatabaseNote>> _noteStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _noteStreamController.stream.filter((note) {
        final currentuser = _user;
        if (currentuser != null) {
          return note.userId == currentuser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotesException();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _catchNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    //Make sure note exists
    await getNote(id: note.id);

    //Update note
    final updateCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id =?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNotes = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNotes.id);
      _notes.add(updatedNotes);
      _noteStreamController.add(_notes);
      return updatedNotes;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _noteStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _noteStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //Create User Table
      await db.execute(createUserTable);
      //Create Note Table
      await db.execute(createNoteTable);
      await _catchNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(
      userTable,
      {
        emailColumn: email,
      },
    );
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    //Make sure owner exists in the database
    final dbOwner = await getUser(email: owner.email);
    if (dbOwner != owner) {
      throw CouldNotFindUserException();
    }
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: dbOwner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _noteStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _noteStreamController.add(_notes);
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'person, id = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Notes Id = $id, User Id = $userId,Synced = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const String dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
            "id"	INTEGER NOT NULL,
            "email"	TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
           ); ''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
            "id"	INTEGER NOT NULL,
            "user_id"	INTEGER NOT NULL,
             "text"	TEXT,
           "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
             PRIMARY KEY("id" AUTOINCREMENT),
            FOREIGN KEY("user_id") REFERENCES "user"("id")
            );''';
