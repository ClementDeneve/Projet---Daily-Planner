import 'package:flutter/material.dart';
import '../todo_manager.dart';

class EditTodoPage extends StatefulWidget {
  final Todo? todo;
  const EditTodoPage({super.key, this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descController = TextEditingController(text: widget.todo?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (optionnelle)'),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) return;
                    final result = <String, dynamic>{
                      'title': title,
                      'description': _descController.text.trim(),
                      'deadline': DateTime.now().add(const Duration(hours: 1)),
                    };
                    if (widget.todo != null) {
                      result['id'] = widget.todo!.id;
                    }
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
