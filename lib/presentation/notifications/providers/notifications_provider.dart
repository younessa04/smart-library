import 'package:flutter/material.dart';
import '../../../domain/entities/favorite_notification_entity.dart';
import '../../../domain/repositories/repository_interfaces.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationsProvider({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _notificationRepository.getUserNotifications(userId);
      _unreadCount = await _notificationRepository.getUnreadCount(userId);
    } catch (e) {
      // silent
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationRepository.markAsRead(userId, notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      _unreadCount = (_unreadCount - 1).clamp(0, 999999);
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await _notificationRepository.deleteNotification(userId, notificationId);
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  Future<void> markAllAsRead(String userId) async {
    for (final n in _notifications.where((n) => !n.read)) {
      await markAsRead(userId, n.id);
    }
  }
}
