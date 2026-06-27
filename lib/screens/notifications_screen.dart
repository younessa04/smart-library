import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/state_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _authService = AuthService();
  final _db = DatabaseService();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final notifs = await _db.getUserNotifications(user.id);
        if (!mounted) return;
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notifId) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;
    await _db.markNotificationAsRead(user.id, notifId);
    await _loadNotifications();
  }

  Future<void> _deleteNotification(String notifId) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;
    await _db.deleteNotification(user.id, notifId);
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;
    for (final n in _notifications.where((n) => n['read'] != true)) {
      await _db.markNotificationAsRead(user.id, n['id']);
    }
    await _loadNotifications();
  }

  int get _unreadCount =>
      _notifications.where((n) => n['read'] != true).length;

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'reservation_accepted':
        return Icons.bookmark_added;
      case 'book_available':
        return Icons.book;
      case 'return_reminder':
        return Icons.schedule;
      case 'new_book':
        return Icons.new_releases;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout marquer lu',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.notifications_none,
                  title: 'Aucune notification',
                  subtitle: 'Vos notifications apparaîtront ici',
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['read'] == true;
                      return Dismissible(
                        key: Key(notif['id'] ?? ''),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            _deleteNotification(notif['id'] ?? ''),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isRead
                              ? null
                              : AppColors.primary.withValues(alpha: 0.05),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                _getTypeIcon(notif['type'] ?? ''),
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              notif['title'] ?? '',
                              style: TextStyle(
                                fontWeight:
                                    isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif['body'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.formatRelativeDate(
                                    (notif['date'] as dynamic).toDate(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing: isRead
                                ? null
                                : Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                            onTap: () => _markAsRead(notif['id'] ?? ''),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
