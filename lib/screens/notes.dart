import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:short_note/providers/user_notes.dart';
import 'package:short_note/screens/add_note.dart';
import 'package:short_note/widgets/note_list.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(userNotesProvider.notifier).loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(userNotesProvider);

    return Scaffold(
      appBar: AppBar(
          elevation: 5,
          shadowColor: Color.fromARGB(255, 250, 224, 77),
          title: Text(
            "Short Notes",
            style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: NotesList(notes: notes),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddNoteScreen(),
          ));
        },
        tooltip: 'New Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
