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

class _TodoListItem extends StatefulWidget {
  final Todo todo;
  final TodoManager manager;
  final AnimationController spinController;
  final VoidCallback onChanged;
  const _TodoListItem({required this.todo, required this.manager, required this.spinController, required this.onChanged});

  @override
  State<_TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<_TodoListItem> with SingleTickerProviderStateMixin {
  bool _animating = false;

  Future<void> _handleCheck() async {
    if (_animating) return;
    setState(() => _animating = true);
    // brief fade-out
    await Future.delayed(const Duration(milliseconds: 250));
    final ok = await widget.manager.markCompleted(widget.todo.id);
    // trigger parent refresh
    widget.onChanged();
    if (!ok) {
      // if failed, reset animation state
      setState(() => _animating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _animating ? 0.0 : 1.0,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: Checkbox(
            value: widget.todo.isCompleted,
            onChanged: (v) async {
              if (v == true) await _handleCheck();
            },
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.todo.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (widget.todo.isDailyRecurring)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: AnimatedBuilder(
                    animation: widget.spinController,
                    builder: (context, child) => Transform.rotate(
                      angle: widget.spinController.value * 2 * 3.1415926535,
                      child: child,
                    ),
                    child: const Icon(Icons.autorenew, size: 16.0, color: Colors.blueAccent),
                  ),
                ),
            ],
          ),
          onTap: () async {
            final updated = await Navigator.of(context).push<Map<String, dynamic>?>(
              MaterialPageRoute(
                builder: (_) => EditTodoPage(todo: widget.todo),
              ),
            );
            if (updated != null && updated.containsKey('id')) {
              final newTodo = widget.todo.copyWith(
                title: updated['title'] as String?,
                description: updated['description'] as String?,
                deadline: updated['deadline'] as DateTime?,
                isDailyRecurring: updated['isDailyRecurring'] as bool? ?? widget.todo.isDailyRecurring,
              );
              final ok = await widget.manager.updateTodo(newTodo);
              if (ok) widget.onChanged();
            }
          },
        ),
      ),
    );
  }
}

class _TodoListPageState extends State<TodoListPage> with SingleTickerProviderStateMixin {
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
  late final AnimationController _spinController;
  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }
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
                            icon: Icon((_collapsed[label] ?? false) ? Icons.expand_more : Icons.expand_less),
                            onPressed: () => setState(() => _collapsed[label] = !(_collapsed[label] ?? false)),
                          ),
                          onTap: () => setState(() => _collapsed[label] = !(_collapsed[label] ?? false)),
                        ),
                      );
                      if (!(_collapsed[label] ?? false)) {
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
                            child: _TodoListItem(
                              todo: t,
                              manager: widget.manager,
                              spinController: _spinController,
                              onChanged: () => setState(() {}),
                            ),
                          );
                        }).toList());
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
