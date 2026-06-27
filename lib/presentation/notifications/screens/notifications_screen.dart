import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          Provider.of<NotificationsProvider>(context, listen: false).loadNotifications(userId);
        }
      }
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'reservation_accepted': return Icons.bookmark_added;
      case 'book_available': return Icons.book;
      case 'return_reminder': return Icons.schedule;
      case 'new_book': return Icons.new_releases;
      default: return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(authProvider.user!.id),
              child: const Text('Tout marquer lu', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifProvider.notifications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.notifications_none,
                  title: 'Aucune notification',
                  subtitle: 'Vos notifications apparaîtront ici',
                )
              : RefreshIndicator(
                  onRefresh: () => notifProvider.loadNotifications(authProvider.user!.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifProvider.notifications[index];
                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          notifProvider.deleteNotification(authProvider.user!.id, notif.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: notif.read ? null : AppColors.primary.withValues(alpha: 0.05),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(_getTypeIcon(notif.type), color: AppColors.primary),
                            ),
                            title: Text(notif.title, style: TextStyle(fontWeight: notif.read ? FontWeight.normal : FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(Formatters.formatRelativeDate(notif.date), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                            trailing: notif.read ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                            onTap: () {
                              notifProvider.markAsRead(authProvider.user!.id, notif.id);
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
