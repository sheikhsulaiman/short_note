import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:short_note/models/note_model.dart';
import 'package:short_note/models/todo_model.dart';
import 'package:short_note/providers/user_notes.dart';

class NoteDetailsScreen extends ConsumerStatefulWidget {
  const NoteDetailsScreen({super.key, required this.note});

  final Note note;

  @override
  ConsumerState<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  final TextEditingController _todoTextController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController todoController = TextEditingController();

  void addTodo() {
    final todo = Todo(data: todoController.text, status: false);
    ref.watch(userNotesProvider.notifier).addTodo(widget.note.id, todo);
    setState(() {
      widget.note.todos.add(todo);
      todoController.clear();
    });
  }

  void deleteTodo(int index) {
    setState(() {
      widget.note.todos.removeAt(index);
    });
  }

  void _showDialogForTodo(BuildContext context, Todo todo) {
    _todoTextController.text = todo.data;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          title: const Text('Modify Todo'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todo.data = _todoTextController.text;
                });
                ref
                    .watch(userNotesProvider.notifier)
                    .updateTodoName(todo, _todoTextController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  controller: _todoTextController,
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, Note note) {
    titleController.text = note.title;
    descriptionController.text = note.description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.all(10),
                    ),
                    minimumSize: MaterialStatePropertyAll(
                      Size(double.infinity, double.minPositive),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.note.title = titleController.text;
                      widget.note.description = descriptionController.text;
                    });
                    ref.watch(userNotesProvider.notifier).updateNote(
                        widget.note.id,
                        widget.note.title,
                        widget.note.description);
                    Navigator.of(context).pop();
                    ref.watch(userNotesProvider.notifier).loadNotes();
                  },
                  // () {
                  // Handle form submission here
                  // String title = titleController.text;
                  // String description = descriptionController.text;
                  // You can use the title and description as needed.
                  // },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer.withBlue(50),
        actions: [
          IconButton(
            onPressed: () {
              _showDialog(context, widget.note);
            },
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                "Description",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              )),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 5),
                        blurRadius: 5,
                        blurStyle: BlurStyle.normal,
                        color: Color.fromARGB(255, 219, 219, 219)),
                  ]),
              margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    style: TextStyle(
                        fontSize: 18,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                    widget.note.description.trim().isEmpty
                        ? "..."
                        : widget.note.description,
                  ),
                ),
              )),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 20,
            child: Text(
              "Todos",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.note.todos.length,
              itemBuilder: (context, index) => GestureDetector(
                onLongPress: () {
                  _showDialogForTodo(context, widget.note.todos[index]);
                },
                child: Dismissible(
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  key: Key(widget.note.todos[index].todoId),
                  onDismissed: (direction) {
                    deleteTodo(index);
                    ref
                        .watch(userNotesProvider.notifier)
                        .deleteTodo(widget.note.todos[index].todoId);
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(0, 5),
                            blurRadius: 5,
                            blurStyle: BlurStyle.normal,
                            color: Color.fromARGB(255, 219, 219, 219)),
                      ],
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: CheckboxListTile(
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        checkboxShape: const CircleBorder(),
                        dense: true,
                        onChanged: (bool? value) {
                          setState(() {
                            widget.note.todos[index].status = value!;
                            ref
                                .watch(userNotesProvider.notifier)
                                .updateTodo(widget.note.todos[index]);
                          });
                        },
                        value: widget.note.todos[index].status,
                        title: Text(
                          widget.note.todos[index].data,
                          style: TextStyle(
                              overflow: TextOverflow.visible,
                              decoration: widget.note.todos[index].status
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: widget.note.todos[index].status
                                  ? Colors.red[400]
                                  : Colors.black),
                        )),
                  ),
                ),
              ),
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      hintText: 'Enter a new todo...',
                    ),
                  ),
                ),
                IconButton(
                  style: ButtonStyle(
                      side: MaterialStatePropertyAll(BorderSide(
                          width: 1.0,
                          color: Theme.of(context).colorScheme.secondary))),
                  icon: Icon(Icons.add,
                      color: Theme.of(context).colorScheme.secondary),
                  onPressed: () {
                    addTodo();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
