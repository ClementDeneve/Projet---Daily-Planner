import 'todo_model.dart';
import 'todo_db.dart';

class TodoManager {
  final List<Todo> _todos = [];
  final List<Todo> _archive = [];
  bool _initialized = false;

  // Initialize and load from database. Call once at startup.
  Future<void> init() async {
    if (_initialized) return;
    final all = await TodoDb.instance.getAllTodos();
    _todos.clear();
    _archive.clear();
    for (var t in all) {
      if (t.isCompleted) {
        _archive.add(t);
      } else {
        _todos.add(t);
      }
    }
    _initialized = true;
  }

  // Return active todos sorted by nearest deadline (ascending)
  List<Todo> getActiveTodos() {
    final active = _todos.where((t) => !t.isCompleted).toList();
    active.sort((a, b) => a.deadline.compareTo(b.deadline));
    return List.unmodifiable(active);
  }

  // Return archived (completed) todos, most recently completed first
  List<Todo> getArchivedTodos() {
    final archived = List<Todo>.from(_archive);
    archived.sort((a, b) {
      final at = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    return List.unmodifiable(archived);
  }

  // Add a new todo. Generates a simple id if none provided.
  Future<Todo> addTodo({required String title, String? description, required DateTime deadline, String? id}) async {
    final newId = id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final todo = Todo(
      id: newId,
      title: title,
      description: description,
      deadline: deadline,
    );
    _todos.add(todo);
    await TodoDb.instance.insertTodo(todo);
    return todo;
  }

  // Remove a todo by id from either active list or archive. Returns true if removed.
  Future<bool> removeTodoById(String id) async {
    final beforeActive = _todos.length;
    _todos.removeWhere((t) => t.id == id);
    if (_todos.length < beforeActive) {
      await TodoDb.instance.deleteTodo(id);
      return true;
    }

    final beforeArchive = _archive.length;
    _archive.removeWhere((t) => t.id == id);
    if (_archive.length < beforeArchive) {
      await TodoDb.instance.deleteTodo(id);
      return true;
    }
    return false;
  }

  // Mark an active todo as completed and move it to archive.
  Future<bool> markCompleted(String id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    final t = _todos.removeAt(idx);
    final completed = t.copyWith(isCompleted: true, completedAt: DateTime.now());
    _archive.add(completed);
    await TodoDb.instance.updateTodo(completed);
    return true;
  }

  // Optionally restore an archived todo back to active
  Future<bool> restoreFromArchive(String id) async {
    final idx = _archive.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    final t = _archive.removeAt(idx);
    final restored = t.copyWith(isCompleted: false, completedAt: null);
    _todos.add(restored);
    await TodoDb.instance.updateTodo(restored);
    return true;
  }

  // Update an existing todo by replacing fields from the provided todo.
  // Returns true if update succeeded.
  Future<bool> updateTodo(Todo updated) async {
    final idx = _todos.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _todos[idx] = updated;
      await TodoDb.instance.updateTodo(updated);
      return true;
    }
    final idxA = _archive.indexWhere((t) => t.id == updated.id);
    if (idxA != -1) {
      _archive[idxA] = updated;
      await TodoDb.instance.updateTodo(updated);
      return true;
    }
    return false;
  }

  // Convenience: clear all todos and archives
  Future<void> clearAll() async {
    _todos.clear();
    _archive.clear();
    final db = await TodoDb.instance.database;
    await db.delete('todos');
  }
}
