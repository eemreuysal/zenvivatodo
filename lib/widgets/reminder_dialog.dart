import 'package:flutter/material.dart';
import '../models/task.dart';

class ReminderDialog extends StatelessWidget {
  final Task task;
  final VoidCallback onDismiss;
  final VoidCallback onViewTask;

  const ReminderDialog({
    Key? key,
    required this.task,
    required this.onDismiss,
    required this.onViewTask,
  }) 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.orange),
          SizedBox(width: 10),
          Text('Görev Hatırlatıcısı'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Göreviniz 5 dakika içinde başlayacak!'),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              task.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 5),
              Text(
                task.time ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Kapat'),
        ),
        ElevatedButton(
          onPressed: onViewTask,
          child: const Text('Görevi Görüntüle'),
        ),
      ],
    );
  }
}
