import 'package:flutter/material.dart';
import 'package:daily_planner/todolist/todo_manager.dart';

class ProfilePage extends StatelessWidget {
  final TodoManager manager;
  const ProfilePage({super.key, required this.manager});

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final birth = DateTime(1999, 7, 28);
    final age = _calculateAge(birth);
    final completedCount = manager.getArchivedTodos().length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                _buildInfoRow(context, 'Nom', 'Kimo'),
                const Divider(height: 1),
                _buildInfoRow(context, 'Âge', '$age ans'),
                const Divider(height: 1),
                _buildInfoRow(context, 'Tâches réalisées', '$completedCount'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
