import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api';
    } else {
      return 'http://localhost:5001/api';
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(Uri.parse('$baseUrl$endpoint'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> uploadImage(dynamic file) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // For web, file is XFile
    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: file.name,
    );
    
    request.files.add(multipartFile);
    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
