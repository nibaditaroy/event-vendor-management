import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/notifications');
      final data = jsonDecode(response.body);
      if (data['success']) {
        _notifications = data['data'];
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await ApiService.put('/notifications/$id/read', {});
      final data = jsonDecode(response.body);
      if (data['success']) {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['is_read'] = true;
          notifyListeners();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.put('/notifications/mark-all-read', {});
      final data = jsonDecode(response.body);
      if (data['success']) {
        for (var n in _notifications) {
          n['is_read'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
