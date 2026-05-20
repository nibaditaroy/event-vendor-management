import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = 'organizer'; // 'organizer' or 'vendor'

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;

  void setRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;
    
    final userData = prefs.getString('user');
    if (userData != null) {
      final user = jsonDecode(userData);
      _userRole = user['role'];
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {'email': email, 'password': password});
      final data = jsonDecode(response.body);
      
      if (data['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        
        _isAuthenticated = true;
        _userRole = data['user']['role'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password, String role, {int? categoryId}) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        if (categoryId != null) 'categoryId': categoryId,
      });
      final data = jsonDecode(response.body);
      return data['success'];
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.put('/auth/profile', userData);
      final data = jsonDecode(response.body);
      
      if (data['success']) {
        final prefs = await SharedPreferences.getInstance();
        // The backend returns the updated user in data['data']
        await prefs.setString('user', jsonEncode(data['data']));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await ApiService.put('/auth/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      final data = jsonDecode(response.body);
      return data['success'];
    } catch (e) {
      return false;
    }
  }
}
