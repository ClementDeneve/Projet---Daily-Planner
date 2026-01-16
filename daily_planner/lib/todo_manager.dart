class Todo {
  final String id;
  String title;
  String? description;
  DateTime deadline;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class TodoManager {
  final List<Todo> _todos = [];
  final List<Todo> _archive = [];

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
  Todo addTodo({required String title, String? description, required DateTime deadline, String? id}) {
    final newId = id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final todo = Todo(
      id: newId,
      title: title,
      description: description,
      deadline: deadline,
    );
    _todos.add(todo);
    return todo;
  }

  // Remove a todo by id from either active list or archive. Returns true if removed.
  bool removeTodoById(String id) {
    final beforeActive = _todos.length;
    _todos.removeWhere((t) => t.id == id);
    if (_todos.length < beforeActive) return true;

    final beforeArchive = _archive.length;
    _archive.removeWhere((t) => t.id == id);
    return _archive.length < beforeArchive;
  }

  // Mark an active todo as completed and move it to archive.
  bool markCompleted(String id) {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    final t = _todos.removeAt(idx);
    final completed = t.copyWith(isCompleted: true, completedAt: DateTime.now());
    _archive.add(completed);
    return true;
  }

  // Optionally restore an archived todo back to active
  bool restoreFromArchive(String id) {
    final idx = _archive.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    final t = _archive.removeAt(idx);
    final restored = t.copyWith(isCompleted: false, completedAt: null);
    _todos.add(restored);
    return true;
  }

  // Convenience: clear all todos and archives
  void clearAll() {
    _todos.clear();
    _archive.clear();
  }
}

// Usage example (comment):
// final manager = TodoManager();
// manager.addTodo(title: 'Buy milk', deadline: DateTime.now().add(Duration(hours: 4)));
// final list = manager.getActiveTodos();
// manager.markCompleted(list.first.id);
// final archives = manager.getArchivedTodos();
