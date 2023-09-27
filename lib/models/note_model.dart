import 'package:short_note/models/todo_model.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Note {
  Note(
      {required this.title,
      required this.description,
      required this.todos,
      String? id})
      : id = id ?? uuid.v4();
  final String id;
  String title;
  String description;
  List<Todo> todos;
}
