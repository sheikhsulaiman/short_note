import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:short_note/models/todo_model.dart';
import 'package:short_note/providers/user_notes.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  List<Todo> todos = [];
  TextEditingController todoController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void saveNote() {
    // final takenNote = Note(
    //     title: titleController.text,
    //     description: descriptionController.text,
    //     todos: todos);
    // print(todos);
    ref
        .read(userNotesProvider.notifier)
        .addNote(titleController.text, descriptionController.text, todos);

    Navigator.of(context).pop();
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  void addTodo() {
    setState(() {
      final todo = Todo(data: todoController.text, status: false);
      todos.add(todo);
      todoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: titleController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              const SizedBox(
                  height: 16.0), // Add spacing between fields and the list
              // ... (other form fields and widgets)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Checkbox(
                        value: todos[index].status,
                        onChanged: (bool? value) {
                          setState(() {
                            todos[index].status = value!;
                          });
                        },
                      ),
                      title: Text(todos[index].data),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteTodo(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: const InputDecoration(
                          hintText: 'Enter a new todo...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        addTodo();
                      },
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                    EdgeInsets.all(10),
                  ),
                  minimumSize: MaterialStatePropertyAll(
                    Size(double.infinity, double.minPositive),
                  ),
                ),
                onPressed: saveNote,
                // () {
                // Handle form submission here
                // String title = titleController.text;
                // String description = descriptionController.text;
                // You can use the title and description as needed.
                // },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
