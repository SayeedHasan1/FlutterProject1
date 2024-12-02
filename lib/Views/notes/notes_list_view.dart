import 'package:flutter/material.dart';
import 'package:fluttertest23/services/cloud/cloud_note.dart';
import 'package:fluttertest23/utilities/dialog/delete_dialog.dart';

typedef NoteCallBack = void Function(CloudNote note);

class NoteslistView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;

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
        final note = notes.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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
