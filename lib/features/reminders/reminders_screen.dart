import 'package:flutter/material.dart';
import '../../core/database/database.dart';
import '../../core/database/contacts_dao.dart';
import '../../core/models/contact.dart' as model;
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _dao = ContactsDao(AppDatabase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REMINDERS")),
      body: DotGridBackground(
        child: FutureBuilder<List<model.Contact>>(
          future: _dao.getOverdueReminders(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final reminders = snapshot.data!;
            if (reminders.isEmpty) {
              return const Center(child: Text("No overdue reminders", style: TextStyle(color: AppTheme.stone)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final c = reminders[index];
                return Card(
                  child: ListTile(
                    title: Text(c.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(c.reminderNote ?? 'Follow up', style: Theme.of(context).textTheme.bodyMedium),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryBlue),
                      onPressed: () async {
                        await _dao.markReminderDone(c.id);
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
