import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:short_note/models/note_model.dart';
import 'package:short_note/providers/user_notes.dart';
import 'package:short_note/screens/note_details.dart';

class NotesList extends ConsumerStatefulWidget {
  const NotesList({super.key, required this.notes});

  final List<Note> notes;

  @override
  ConsumerState<NotesList> createState() => _NotesListState();
}

class _NotesListState extends ConsumerState<NotesList> {
  void _removeNote(index, String id) {
    setState(() {
      widget.notes.removeAt(index);
    });
    ref.watch(userNotesProvider.notifier).deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return const Center(
        child: Text("No notes found!"),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(widget.notes[index].id),
          onDismissed: (direction) =>
              _removeNote(index, widget.notes[index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            textColor: Theme.of(context).colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              // side: const BorderSide(
              //   color: Color.fromARGB(255, 190, 115, 255),
              //   width: 1,
              // ),
              borderRadius: BorderRadius.circular(10),
            ),
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            tileColor:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(.7),
            title: Text(widget.notes[index].title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            dense: true,
            contentPadding: const EdgeInsets.only(left: 15),
            trailing: IconButton(
              color: Theme.of(context).colorScheme.error.withOpacity(.8),
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _removeNote(index, widget.notes[index].id),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NoteDetailsScreen(note: widget.notes[index]),
              ));
            },
          ),
        );
      },
    );
  }
}
