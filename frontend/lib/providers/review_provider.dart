import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  List<dynamic> _vendorReviews = [];
  bool _isLoading = false;

  List<dynamic> get vendorReviews => _vendorReviews;
  bool get isLoading => _isLoading;

  Future<void> fetchVendorReviews(int vendorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/reviews/vendor/$vendorId');
      final data = jsonDecode(response.body);
      if (data['success']) {
        _vendorReviews = data['data'];
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview(int bookingId, int vendorId, double rating, String comment) async {
    try {
      final response = await ApiService.post('/reviews', {
        'booking_id': bookingId,
        'vendor_id': vendorId,
        'rating': rating,
        'comment': comment
      });
      final data = jsonDecode(response.body);
      return data['success'];
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }
}
