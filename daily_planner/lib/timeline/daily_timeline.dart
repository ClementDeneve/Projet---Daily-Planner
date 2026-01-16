import 'package:flutter/material.dart';
import 'package:daily_planner/todolist/todo_manager.dart';

class DailyTimeline extends StatefulWidget {
  final TodoManager manager;
  const DailyTimeline({Key? key, required this.manager}) : super(key: key);

  @override
  State<DailyTimeline> createState() => _DailyTimelineState();
}

class _DailyTimelineState extends State<DailyTimeline> {
  List<Todo> get _active => widget.manager.getActiveTodos();

  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final events = _active;
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width > 600 ? 600.0 : width * 0.94;
    if (events.isEmpty) {
      return Center(child: Text('Aucune tâche pour aujourd\'hui', style: Theme.of(context).textTheme.bodyLarge));
    }
    return Center(
      child: SizedBox(
        width: contentWidth,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final t = events[index];
            final isLast = index == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 72,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(_formatTime(t.deadline), style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          widget.manager.markCompleted(t.id);
                          setState(() {});
                        },
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title, style: Theme.of(context).textTheme.titleMedium),
                                  if ((t.description ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(t.description!, style: Theme.of(context).textTheme.bodySmall),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                widget.manager.markCompleted(t.id);
                                setState(() {});
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              color: Colors.green,
                              tooltip: 'Marquer comme fait',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

