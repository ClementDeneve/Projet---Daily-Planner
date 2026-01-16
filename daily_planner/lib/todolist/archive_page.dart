import 'package:flutter/material.dart';
import 'package:daily_planner/todolist/todo_manager.dart';
import 'package:daily_planner/todolist/todo_model.dart';
import 'edit_todo_page.dart';

class ArchivePage extends StatefulWidget {
  final TodoManager manager;
  const ArchivePage({super.key, required this.manager});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String _shortDate(DateTime dt) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final archived = widget.manager.getArchivedTodos();
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: archived.isEmpty
            ? Center(child: Text('Aucune tâche complétée', style: Theme.of(context).textTheme.bodyLarge))
            : ListView.builder(
                itemCount: archived.length,
                itemBuilder: (context, index) {
                  final t = archived[index];
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
                        subtitle: t.completedAt != null ? Text('Complétée le ${_shortDate(t.completedAt!)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)) : null,
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
                                isDailyRecurring: updated['isDailyRecurring'] as bool? ?? t.isDailyRecurring,
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
                },
              ),
      ),
    );
  }
}
