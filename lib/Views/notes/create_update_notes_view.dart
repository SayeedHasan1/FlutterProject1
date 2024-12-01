import 'package:flutter/material.dart';
import 'package:fluttertest23/services/auth/auth_service.dart';
import 'package:fluttertest23/utilities/dialog/cannot_share_empty_dialogue.dart';
import 'package:fluttertest23/utilities/generic/get_arguments.dart';
import 'package:fluttertest23/services/cloud/cloud_note.dart';
import 'package:fluttertest23/services/cloud/firebase_cloud_storage.dart';
import 'package:fluttertest23/services/cloud/cloud_storage_exception.dart';
import 'package:share_plus/share_plus.dart';

class CreateupdateNotesView extends StatefulWidget {
  const CreateupdateNotesView({super.key});

  @override
  State<CreateupdateNotesView> createState() => _CreateupdateNotesViewState();
}

class _CreateupdateNotesViewState extends State<CreateupdateNotesView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
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
        documentId: note.documentId,
        text: text,
      );
    }
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNotee(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _noteService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  Future<void> _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      _noteService.updateNote(
        documentId: note.documentId,
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
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyDialogue(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
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
