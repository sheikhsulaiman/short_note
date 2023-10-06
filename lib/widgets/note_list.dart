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
    return GridView.builder(
      primary: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 150),
      // separatorBuilder: (context, index) => const SizedBox(
      //   height: 10,
      // ),
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
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NoteDetailsScreen(note: widget.notes[index]),
              ));
            },
            child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          blurRadius: 5,
                          color: Color.fromARGB(255, 219, 219, 219),
                          blurStyle: BlurStyle.normal,
                          offset: Offset(5, 5))
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).colorScheme.primaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withBlue(50)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        child: Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  widget.notes[index].title.toUpperCase(),
                                  style: TextStyle(
                                      overflow: TextOverflow.fade,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _removeNote(index, widget.notes[index].id);
                                  },
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.notes[index].description,
                          style: const TextStyle(overflow: TextOverflow.fade),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }
}
