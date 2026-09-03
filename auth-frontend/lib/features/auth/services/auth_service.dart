import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; 
    }
    return 'http://127.0.0.1:8000/api'; 
  }

  // Helper headers
  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'success': true,
        'token': data['access_token'],
        'user': User.fromJson(data['user']),
      };
    }

    return {
      'success': false,
      'message': data['message'] ?? 'Registration failed',
      'errors': data['errors'],
    };
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'token': data['access_token'],
        'user': User.fromJson(data['user']),
      };
    }

    return {
      'success': false,
      'message': data['message'] ?? 'Login failed',
      'errors': data['errors'],
    };
  }

  // Get Current User (/api/me)
  Future<User?> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }

    return null;
  }

  // Logout
  Future<bool> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(token),
    );

    return response.statusCode == 200;
  }
}