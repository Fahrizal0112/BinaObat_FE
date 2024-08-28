import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://36a1-2404-8000-1024-1787-c553-cfbb-3244-d321.ngrok-free.app/auth';
  String? token;

  Future<Map<String, dynamic>> signup(String fullname, String email, String password, String phone, String token) async {
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
          'token': token
        }),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Signup failed with status code: ${response.body}');
        return {'error': 'Failed to sign up'};
      }
    } catch (e) {
      debugPrint('An error occurred during signup: $e');
      return {'error': 'An error occurred during signup'};
    }
  }

  Future<Map<String, dynamic>> signuppatient(String fullname, String email, String password, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('No token found for doctor.');
        return {'error': 'No token found', 'status_code': 401};
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/signup-patient'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token', 
        },
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
          'phonenumber': phone,
        }),
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('Patient signup successful: ${responseData['message']}');
        return responseData;
      } else {
        debugPrint('Signup failed with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        final errorData = jsonDecode(response.body);
        return {
          'error': errorData['error'] ?? 'Unknown error', 
          'response_body': response.body,
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('An error occurred during signup: $e');
      return {'error': 'An error occurred during signup', 'status_code': 500};
    }
  }

  Future<Map<String, dynamic>> deletePatient(String patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Error: Token is null');
        return {'error': 'Token not available'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/delete-patient/$patientId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('Patient deleted successfully: ${responseData['message']}');
        return responseData;
      } else {
        debugPrint('Failed to delete patient with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        final errorData = json.decode(response.body);
        return {
          'error': errorData['error'] ?? 'Failed to delete patient',
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('An error occurred during patient deletion: $e');
      return {'error': 'An error occurred during patient deletion'};
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
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            
            if (data['user'] != null && data['user']['role'] != null) {
              await prefs.setString('userRole', data['user']['role']);
            }
            
            return data;
          } else {
            return {'error': 'Token not found'};
          }
        } else {
          return {'error': 'Set-Cookie header not found'};
        }
      } else {
        return {'error': 'Failed to sign in'};
      }
    } catch (e) {
      return {'error': 'An error occurred during signin'};
    }
  }


  Future<Map<String, dynamic>> signout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        // debugPrint('No token found to sign out.');
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
        // debugPrint('Failed to sign out with status code: ${response.statusCode}');
        return {'error': 'Failed to sign out'};
      }
    } catch (e) {
      // debugPrint('An error occurred during signout: $e');
      return {'error': 'An error occurred during signout'};
    }
  }

    Future<Map<String, dynamic>> getPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Error: Token is null');
        return {'error': 'Token not available'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get-patients'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to fetch patients with status code: ${response.statusCode}');
        return {'error': 'Failed to fetch patients'};
      }
    } catch (e) {
      debugPrint('An error occurred during fetching patients: $e');
      return {'error': 'An error occurred during fetching patients'};
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
      
      // debugPrint('Token used: $token');
      // debugPrint('Response status code: ${response.statusCode}');
      // debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // debugPrint('Failed to fetch full name with status code: ${response.statusCode}');
        return {'error': 'Failed to fetch full name'};
      }
    } catch (e) {
      // debugPrint('An error occurred during fetching full name: $e');
      return {'error': 'An error occurred during fetching full name'};
    }
  }

  Future<Map<String, dynamic>> getPrescriptionDetails(String prescriptionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Error: Token is null');
        return {'error': 'Token not available', 'status_code': 401};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/prescription/$prescriptionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final prescription = responseData['prescription'];
        final medications = prescription['medications'] as List;
        
        final simplifiedMedications = medications.map((med) => {
          'name': med['name'],
          'dosage': med['dosage'],
          'frequency': med['frequency'],
        }).toList();

        return {
          'status_code': 200,
          'medications': simplifiedMedications,
        };
      } else {
        debugPrint('Failed to fetch prescription details with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        final errorData = json.decode(response.body);
        return {
          'error': errorData['error'] ?? 'Failed to fetch prescription details',
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('An error occurred while fetching prescription details: $e');
      return {
        'error': 'An error occurred while fetching prescription details',
        'status_code': 500
      };
    }
  }

  Future<Map<String, dynamic>> getPrescriptionsId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'error': 'Token not available'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/prescriptionsid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to fetch prescriptions with status code: ${response.statusCode}');
        return {'error': 'Failed to fetch prescriptions'};
      }
    } catch (e) {
      print('An error occurred during fetching prescriptions: $e');
      return {'error': 'An error occurred during fetching prescriptions'};
    }
  }

  Future<Map<String, dynamic>> prescribe(String patientId, List<Map<String, String>> medications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Error: Token is null');
        return {'error': 'Token not available', 'status_code': 401};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/prescribe'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'medications': medications,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'status_code': 200,
          'message': responseData['message'],
        };
      } else {
        debugPrint('Failed to prescribe with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        final errorData = json.decode(response.body);
        return {
          'error': errorData['error'] ?? 'Failed to prescribe',
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('An error occurred while prescribing: $e');
      return {
        'error': 'An error occurred while prescribing',
        'status_code': 500
      };
    }
  }

  Future<Map<String, dynamic>> createDoctorToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Error: Token is null');
        return {'error': 'Token not available', 'status_code': 401};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/create-doctor-token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': ' token=$token',
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'message': responseData['message'],
          'token': responseData['token'],
        };
      } else {
        debugPrint('Failed to create doctor token with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        final errorData = json.decode(response.body);
        return {
          'error': errorData['error'] ?? 'Failed to create doctor token',
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('An error occurred while creating doctor token: $e');
      return {
        'error': 'An error occurred while creating doctor token',
        'status_code': 500
      };
    }
  }
}

