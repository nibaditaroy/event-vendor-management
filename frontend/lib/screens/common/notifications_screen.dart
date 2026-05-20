import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('NOTIFICATIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => notificationProvider.markAllAsRead(),
            child: const Text('Mark all as read', style: TextStyle(fontSize: 10, color: Colors.blue)),
          ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationProvider.notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Updates about your deals will appear here.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    Color typeColor = Colors.blue;
    IconData typeIcon = Icons.notifications;

    switch (notification['type']) {
      case 'success':
        typeColor = Colors.green;
        typeIcon = Icons.check_circle_outline;
        break;
      case 'reminder':
        typeColor = Colors.orange;
        typeIcon = Icons.access_time;
        break;
      case 'payment':
        typeColor = Colors.purple;
        typeIcon = Icons.payments_outlined;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!notification['is_read']) {
          Provider.of<NotificationProvider>(context, listen: false).markAsRead(notification['id']);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['is_read'] ? Colors.white : typeColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notification['is_read'] ? Colors.grey.shade100 : typeColor.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(typeIcon, size: 20, color: typeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notification['title'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      if (!notification['is_read'])
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification['message'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(notification['createdAt'].toString().split('T')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
