import 'package:flutter/material.dart';
import 'package:fluttertest23/services/auth/auth_service.dart';
import 'package:fluttertest23/services/crud/notes_service.dart';
import 'package:fluttertest23/utilities/generic/get_arguments.dart';

class CreateupdateNotesView extends StatefulWidget {
  const CreateupdateNotesView({super.key});

  @override
  State<CreateupdateNotesView> createState() => _CreateupdateNotesViewState();
}

class _CreateupdateNotesViewState extends State<CreateupdateNotesView> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _noteService = NoteService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    } else {
      final text = _textController.text;
      await _noteService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNotee(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currenUser = AuthService.firebase().currentUser!;
    final email = currenUser.email;
    final owner = await _noteService.getUser(email: email);
    final newNote = await _noteService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  Future<void> _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(id: note.id);
    }
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      _noteService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNotee(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();

              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start typing from here....'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
