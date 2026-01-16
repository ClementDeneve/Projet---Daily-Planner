import 'package:flutter/material.dart';
import '../todo_manager.dart';
import 'edit_todo_page.dart';

class TodoListPage extends StatefulWidget {
  final TodoManager manager;
  const TodoListPage({super.key, required this.manager});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  Widget build(BuildContext context) {
    final todos = widget.manager.getActiveTodos();
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
            child: todos.isEmpty
                ? Center(child: Text('Aucun todo actif', style: Theme.of(context).textTheme.bodyLarge))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final t = todos[index];
                      final time = '${t.deadline.hour.toString().padLeft(2, '0')}:${t.deadline.minute.toString().padLeft(2, '0')} ${t.deadline.day}/${t.deadline.month}';
                      return Dismissible(
                        key: ValueKey(t.id),
                        background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(Icons.delete, color: Colors.white)),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          setState(() {
                            widget.manager.removeTodoById(t.id);
                          });
                        },
                        child: Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: t.isCompleted,
                              onChanged: (v) {
                                if (v == true) {
                                  setState(() {
                                    widget.manager.markCompleted(t.id);
                                  });
                                }
                              },
                            ),
                            title: Text(t.title),
                            subtitle: Text(time + (t.description != null ? ' · ${t.description}' : '')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async {
                                    final updated = await Navigator.of(context).push<Map<String, dynamic>?>(
                                      MaterialPageRoute(
                                        builder: (_) => EditTodoPage(todo: t),
                                      ),
                                    );
                                    if (updated != null) {
                                      setState(() {
                                        if (updated.containsKey('id')) {
                                          final newTodo = t.copyWith(
                                            title: updated['title'] as String?,
                                            description: updated['description'] as String?,
                                            deadline: updated['deadline'] as DateTime?,
                                          );
                                          widget.manager.updateTodo(newTodo);
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    setState(() {
                                      widget.manager.removeTodoById(t.id);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
