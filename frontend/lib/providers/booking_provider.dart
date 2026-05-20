import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<dynamic> _bookings = [];
  bool _isLoading = false;

  List<dynamic> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/bookings');
      final data = jsonDecode(response.body);
      if (data['success']) {
        _bookings = data['data'];
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await ApiService.post('/bookings', bookingData);
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateStatus(int bookingId, String status) async {
    try {
      final response = await ApiService.put('/bookings/$bookingId/status', {'status': status});
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updatePaymentStatus(int bookingId, String paymentStatus) async {
    try {
      final response = await ApiService.put('/bookings/$bookingId/payment', {'payment_status': paymentStatus});
      final data = jsonDecode(response.body);
      if (data['success']) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
