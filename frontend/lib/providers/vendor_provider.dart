import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VendorProvider with ChangeNotifier {
  List<dynamic> _vendors = [];
  Map<String, dynamic>? _selectedVendor;
  bool _isLoading = false;

  List<dynamic> get vendors => _vendors;
  Map<String, dynamic>? get selectedVendor => _selectedVendor;
  bool get isLoading => _isLoading;

  Future<void> fetchVendors({int? categoryId, String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = '/vendors?';
      if (categoryId != null) endpoint += 'category_id=$categoryId&';
      if (search != null && search.isNotEmpty) endpoint += 'search=$search';
      
      final response = await ApiService.get(endpoint);
      final data = jsonDecode(response.body);
      if (data['success']) {
        _vendors = data['data'];
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendorById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/vendors/$id');
      final data = jsonDecode(response.body);
      if (data['success']) {
        _selectedVendor = data['data'];
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCurrentVendor() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/vendors/profile');
      final data = jsonDecode(response.body);
      if (data['success']) {
        _selectedVendor = data['data'];
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await ApiService.put('/vendors/profile', profileData);
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchCurrentVendor();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
