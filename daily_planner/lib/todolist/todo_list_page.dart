import 'package:flutter/material.dart';
import 'package:daily_planner/todolist/todo_manager.dart';
import 'package:daily_planner/todolist/todo_model.dart';
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

  Map<String, List<Todo>> _buildDeadlineBuckets(List<Todo> active) {
    final Map<String, List<Todo>> buckets = <String, List<Todo>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final t in active) {
      final dl = DateTime(t.deadline.year, t.deadline.month, t.deadline.day);
      final diff = dl.difference(today).inDays;
      String label;
      if (diff < 0) {
        label = 'Échu';
      } else if (diff == 0) {
        label = 'Aujourd\'hui';
      } else if (diff == 1) {
        label = 'Demain';
      } else if (diff >= 2 && diff <= 6) {
        label = 'Dans $diff jours';
      } else if (diff >= 7 && diff <= 13) {
        label = 'Dans une semaine';
      } else if (diff >= 14 && diff <= 29) {
        label = 'Dans 2 semaines';
      } else {
        label = 'Dans un mois';
      }
      buckets.putIfAbsent(label, () => <Todo>[]).add(t);
    }
    return buckets;
  }
  // Track collapsed state per bucket label
  final Map<String, bool> _collapsed = {};
  @override
  Widget build(BuildContext context) {
    final active = widget.manager.getActiveTodos();
    final archived = widget.manager.getArchivedTodos();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Active todos grouped by deadline buckets
                if (active.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('Aucun todo actif', style: Theme.of(context).textTheme.bodyLarge)),
                  )
                else ...[
                  // build buckets map and render with collapse headers
                  ...(() {
                    final buckets = _buildDeadlineBuckets(active);
                    final List<Widget> widgets = [];
                    for (final entry in buckets.entries) {
                      final label = entry.key;
                      final items = entry.value;
                      // ensure collapsed state exists
                      _collapsed.putIfAbsent(label, () => false);
                      widgets.add(
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(label, style: Theme.of(context).textTheme.titleMedium),
                          trailing: IconButton(
                            icon: Icon(_collapsed[label]! ? Icons.expand_more : Icons.expand_less),
                            onPressed: () => setState(() => _collapsed[label] = !_collapsed[label]!),
                          ),
                          onTap: () => setState(() => _collapsed[label] = !_collapsed[label]!),
                        ),
                      );
                      if (!_collapsed[label]!) {
                        widgets.addAll(items.map((t) {
                          return Dismissible(
                            key: ValueKey('act-${t.id}'),
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
                        }));
                      }
                    }
                    return widgets;
                  }()),
                ],

                // Archived: moved to separate Archive page
              ],
            ),
          ),
        ],
      ),
    );
  }
}
