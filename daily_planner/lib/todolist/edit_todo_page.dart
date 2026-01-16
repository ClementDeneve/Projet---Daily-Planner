import 'package:flutter/material.dart';
import 'package:daily_planner/todolist/todo_model.dart';

class EditTodoPage extends StatefulWidget {
  final Todo? todo;
  const EditTodoPage({super.key, this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _deadline;
  late bool _isCompleted;
  DateTime? _completedAt;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _descController = TextEditingController(text: todo?.description ?? '');
    _deadline = todo?.deadline ?? DateTime.now().add(const Duration(hours: 1));
    _isCompleted = todo?.isCompleted ?? false;
    _completedAt = todo?.completedAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _toggleCompleted(bool? v) {
    setState(() {
      _isCompleted = v ?? false;
      _completedAt = _isCompleted ? DateTime.now() : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (optionnelle)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12.0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline'),
              subtitle: Text(_formatDateTime(_deadline)),
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: _pickDeadline,
              ),
              onTap: _pickDeadline,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Marquer comme complétée'),
              value: _isCompleted,
              onChanged: _toggleCompleted,
            ),
            if (_completedAt != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Complétée le: ${_formatDateTime(_completedAt!)}', style: Theme.of(context).textTheme.bodySmall),
              ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) return;
                    final result = <String, dynamic>{
                      'title': title,
                      'description': _descController.text.trim(),
                      'deadline': _deadline,
                      'isCompleted': _isCompleted,
                      'completedAt': _completedAt,
                    };
                    if (isEditing) result['id'] = widget.todo!.id;
                    Navigator.of(context).pop(result);
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
