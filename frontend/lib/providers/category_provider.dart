import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  bool _isLoading = false;

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/categories');
      final data = jsonDecode(response.body);
      if (data['success']) {
        final List<dynamic> rawCategories = data['data'];
        final Set<String> seenNames = {};
        _categories = rawCategories.where((cat) {
          final name = cat['name'].toString().toLowerCase().trim();
          if (seenNames.contains(name)) return false;
          seenNames.add(name);
          return true;
        }).toList();
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
