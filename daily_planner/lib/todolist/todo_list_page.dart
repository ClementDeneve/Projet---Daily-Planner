import 'package:flutter/material.dart';
import 'package:daily_planner/todolist/todo_manager.dart';
import 'edit_todo_page.dart';

class TodoListPage extends StatefulWidget {
  final TodoManager manager;
  const TodoListPage({super.key, required this.manager});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  String _shortDate(DateTime dt) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }
  @override
  Widget build(BuildContext context) {
    final active = widget.manager.getActiveTodos();
    final archived = widget.manager.getArchivedTodos();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('To Do', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: ListView(
              children: [
                // Active todos
                if (active.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('Aucun todo actif', style: Theme.of(context).textTheme.bodyLarge)),
                  )
                else
                  ...active.map((t) {
                    return Dismissible(
                      key: ValueKey(t.id),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        final removed = await widget.manager.removeTodoById(t.id);
                        if (removed) setState(() {});
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          leading: Checkbox(
                            value: t.isCompleted,
                            onChanged: (v) async {
                              if (v == true) {
                                final ok = await widget.manager.markCompleted(t.id);
                                if (ok) setState(() {});
                              }
                            },
                          ),
                          title: Text(
                            t.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(_shortDate(t.deadline)),
                          onTap: () async {
                            final updated = await Navigator.of(context).push<Map<String, dynamic>?>(
                              MaterialPageRoute(
                                builder: (_) => EditTodoPage(todo: t),
                              ),
                            );
                            if (updated != null) {
                              if (updated.containsKey('id')) {
                                final newTodo = t.copyWith(
                                  title: updated['title'] as String?,
                                  description: updated['description'] as String?,
                                  deadline: updated['deadline'] as DateTime?,
                                );
                                final ok = await widget.manager.updateTodo(newTodo);
                                if (ok) setState(() {});
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }),

                // Archived / completed todos section
                if (archived.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Complétées', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ...archived.map((t) {
                    return Dismissible(
                      key: ValueKey('arch-${t.id}'),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        final removed = await widget.manager.removeTodoById(t.id);
                        if (removed) setState(() {});
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          leading: Checkbox(
                            value: true,
                            activeColor: Colors.green,
                            onChanged: (v) async {
                              if (v == false) {
                                final ok = await widget.manager.restoreFromArchive(t.id);
                                if (ok) setState(() {});
                              }
                            },
                          ),
                          title: Text(
                            t.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                          subtitle: t.completedAt != null ? Text('Complétée le ${t.completedAt}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)) : null,
                          onTap: () async {
                            final updated = await Navigator.of(context).push<Map<String, dynamic>?>(
                              MaterialPageRoute(
                                builder: (_) => EditTodoPage(todo: t),
                              ),
                            );
                            if (updated != null) {
                              if (updated.containsKey('id')) {
                                final newTodo = t.copyWith(
                                  title: updated['title'] as String?,
                                  description: updated['description'] as String?,
                                  deadline: updated['deadline'] as DateTime?,
                                  isCompleted: updated['isCompleted'] as bool? ?? true,
                                  completedAt: updated['completedAt'] as DateTime?,
                                );
                                final ok = await widget.manager.updateTodo(newTodo);
                                if (ok) setState(() {});
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
