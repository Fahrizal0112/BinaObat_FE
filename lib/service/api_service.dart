import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://01d4-2404-8000-1024-1787-c553-cfbb-3244-d321.ngrok-free.app/auth';
  String? token;

  Future<Map<String, dynamic>> signup(String fullname, String email, String password, String phone, String role) async {
    try {
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
        debugPrint('Signup failed with status code: ${response.statusCode}');
        return {'error': 'Failed to sign up'};
      }
    } catch (e) {
      debugPrint('An error occurred during signup: $e');
      return {'error': 'An error occurred during signup'};
    }
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cookies = response.headers['set-cookie'];

        if (cookies != null) {
          final cookieParts = cookies.split(';');
          String? token;

          for (var part in cookieParts) {
            if (part.trim().startsWith('token=')) {
              token = part.split('=')[1];
              break;
            }
          }

          if (token != null) {
            debugPrint('Token: $token');
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            return data;
          } else {
            debugPrint('Token not found in cookies.');
            return {'error': 'Token not found'};
          }
        } else {
          debugPrint('Set-Cookie header not found.');
          return {'error': 'Set-Cookie header not found'};
        }
      } else {
        debugPrint('Failed to sign in with status code: ${response.statusCode}');
        return {'error': 'Failed to sign in'};
      }
    } catch (e) {
      debugPrint('An error occurred during signin: $e');
      return {'error': 'An error occurred during signin'};
    }
  }

  Future<Map<String, dynamic>> signout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('No token found to sign out.');
        return {'error': 'No token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/signout'),
        headers: {'Cookie': ' token=$token'},
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        return json.decode(response.body);
      } else {
        debugPrint('Failed to sign out with status code: ${response.statusCode}');
        return {'error': 'Failed to sign out'};
      }
    } catch (e) {
      debugPrint('An error occurred during signout: $e');
      return {'error': 'An error occurred during signout'};
    }
  }

  Future<Map<String, dynamic>> getFullName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Error: Token is null');
        return {'error': 'Token not available'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/fullname'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
      );
      
      debugPrint('Token used: $token');
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to fetch full name with status code: ${response.statusCode}');
        return {'error': 'Failed to fetch full name'};
      }
    } catch (e) {
      debugPrint('An error occurred during fetching full name: $e');
      return {'error': 'An error occurred during fetching full name'};
    }
  }
}