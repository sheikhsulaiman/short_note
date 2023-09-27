import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Todo {
  Todo({required this.data, required this.status, String? todoId})
      : todoId = todoId ?? uuid.v4();
  String data;
  final String todoId;
  bool status;
}
