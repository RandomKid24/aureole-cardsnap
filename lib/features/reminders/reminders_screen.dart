import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/database/database.dart';
import '../../core/models/contact.dart' as model;
import '../../core/notifications/notification_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  Future<void> _markDone(String id) async {
    final dao = context.read<AppDatabase>().contactsDao;
    await dao.markReminderDone(id);
    await NotificationService.cancelReminder(id.hashCode);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dao = context.read<AppDatabase>().contactsDao;
    return Scaffold(
      appBar: AppBar(title: const Text("REMINDERS")),
      body: DotGridBackground(
        child: FutureBuilder<List<model.Contact>>(
          future: dao.getPendingReminders(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reminders = snapshot.data!;
            if (reminders.isEmpty) {
              return const Center(
                child: Text("No follow-ups scheduled",
                    style: TextStyle(color: AppTheme.stone)),
              );
            }

            final now = DateTime.now();
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = reminders[index];
                final due = c.reminderDate;
                final overdue = due != null && due.isBefore(now);
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/contact/${c.id}'),
                    title: Text(c.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((c.reminderNote ?? '').isNotEmpty)
                          Text(c.reminderNote!, style: Theme.of(context).textTheme.bodyMedium),
                        if (due != null)
                          Text(
                            overdue
                                ? 'Overdue · ${timeago.format(due)}'
                                : 'Due ${timeago.format(due, allowFromNow: true)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: overdue ? AppTheme.error : AppTheme.stone,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryBlue),
                      tooltip: 'Mark done',
                      onPressed: () => _markDone(c.id),
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
