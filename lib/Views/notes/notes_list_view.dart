import 'package:flutter/material.dart';
import 'package:fluttertest23/services/crud/notes_service.dart';
import 'package:fluttertest23/utilities/dialog/delete_dialog.dart';

typedef NoteCallBack = void Function(DatabaseNote note);

class NoteslistView extends StatelessWidget {
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;
  final List<DatabaseNote> notes;

  const NoteslistView({
    super.key,
    required this.onDeleteNote,
    required this.notes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}