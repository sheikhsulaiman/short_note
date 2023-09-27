import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:short_note/models/note_model.dart';
import 'package:short_note/models/todo_model.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'notes.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE user_notes(id TEXT PRIMARY KEY, title TEXT,description TEXT)');
      await db.execute('PRAGMA foreign_keys = ON');
      await db.execute(
          'CREATE TABLE user_todos(todo_id TEXT PRIMARY KEY, data TEXT,status INT,note_id TEXT,FOREIGN KEY (note_id) REFERENCES user_notes (id) ON DELETE CASCADE )');
    },
    version: 1,
  );
  return db;
}

class UserNotesProvider extends StateNotifier<List<Note>> {
  UserNotesProvider() : super(const []);

  void addNote(String title, String description, List<Todo> todos) async {
    final newNote = Note(title: title, description: description, todos: todos);
    final db = await _getDatabase();
    db.insert('user_notes', {
      'id': newNote.id,
      'title': newNote.title,
      'description': newNote.description,
    });

    for (int i = 0; i < newNote.todos.length; i++) {
      db.insert('user_todos', {
        'note_id': newNote.id,
        'todo_id': newNote.todos[i].todoId,
        'data': newNote.todos[i].data,
        'status': newNote.todos[i].status ? 1 : 0
      });
    }

    state = [newNote, ...state];
  }

  void loadNotes() async {
    final db = await _getDatabase();
    final notesdata = await db.rawQuery('SELECT * FROM user_notes');
    final notes = notesdata.reversed.map(
      (e) async {
        var id = e['id'];
        final todosdata = await db
            .rawQuery('SELECT * FROM user_todos WHERE note_id = ?', ['$id']);
        // .rawQuery("SELECT * FROM user_todos");
        // print(todosdata);
        final todos = todosdata
            .map(
              (x) => Todo(
                  data: x['data'] != null ? x['data'] as String : '',
                  status: x['status'] != null
                      ? x['status'] as num == 1
                          ? true
                          : false
                      : false,
                  todoId: x['todo_id'] != null ? x['todo_id'] as String : ''),
            )
            .toList();
        return Note(
            title: e['title'] != null ? e['title'] as String : '',
            description:
                e['description'] != null ? e['description'] as String : '',
            id: e['id'] != null ? e['id'] as String : '',
            todos: todos);
      },
    ).toList();
    state = await Future.wait(notes);
  }

  void deleteNote(String id) async {
    final db = await _getDatabase();
    await db.rawDelete('DELETE FROM user_notes WHERE id = ?', [id]);
  }

  void deleteTodo(String id) async {
    final db = await _getDatabase();
    await db.rawDelete('DELETE FROM user_todos WHERE todo_id = ?', [id]);
  }

  void updateTodo(Todo todo) async {
    final db = await _getDatabase();
    if (todo.status == true) {
      await db.rawUpdate('UPDATE user_todos SET status = ? WHERE todo_id = ?',
          [1, todo.todoId]);
    } else {
      await db.rawUpdate('UPDATE user_todos SET status = ? WHERE todo_id = ?',
          [0, todo.todoId]);
    }
  }

  void updateNote(id, title, description) async {
    final db = await _getDatabase();

    await db.rawUpdate(
        'UPDATE user_notes SET title = ? , description = ? WHERE id = ?',
        [title, description, id]);
  }

  void addTodo(String noteId, Todo todo) async {
    final db = await _getDatabase();
    db.insert('user_todos', {
      'note_id': noteId,
      'todo_id': todo.todoId,
      'data': todo.data,
      'status': todo.status ? 1 : 0
    });
  }

  void updateTodoName(Todo todo, String data) async {
    final db = await _getDatabase();

    await db.rawUpdate('UPDATE user_todos SET data = ? WHERE todo_id = ?',
        [data, todo.todoId]);
  }
}

final userNotesProvider = StateNotifierProvider<UserNotesProvider, List<Note>>(
    (ref) => UserNotesProvider());
