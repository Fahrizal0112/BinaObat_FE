import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://01d4-2404-8000-1024-1787-c553-cfbb-3244-d321.ngrok-free.app/auth';
  String? token;

  Future<Map<String, dynamic>> signup(String fullname, String email,
      String password, String phone, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'password': password,
        'phonenumber': phone,
        'role': role
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up');
    }
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = json.decode(response.body);
    if (data['token'] != null) {
      token = data['token'];
      debugPrint('Token: $token');
    }
    return data;
  }

  Future<Map<String, dynamic>> signout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/signout'),
      headers: {'token': 'Bearer $token'},
    );
    token = null;
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getFullName() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fullname'),
      headers: {'token': 'Bearer $token'},
    );
    return json.decode(response.body);
  }
}
