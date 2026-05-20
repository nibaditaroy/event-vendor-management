import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<dynamic> _services = [];
  bool _isLoading = false;

  List<dynamic> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/services');
      final data = jsonDecode(response.body);
      if (data['success']) {
        _services = data['data'];
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final response = await ApiService.post('/services', serviceData);
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateService(int id, Map<String, dynamic> serviceData) async {
    try {
      final response = await ApiService.put('/services/$id', serviceData);
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      final response = await ApiService.delete('/services/$id');
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
