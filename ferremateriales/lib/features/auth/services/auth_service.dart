import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl;
  final storage = const FlutterSecureStorage();
  
  AuthService({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Calling login API with email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'password': password
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'auth_token', value: data['token']);
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Error in login: $e');
      rethrow;
    }
  }



  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      print('Registering user with email: $email'); // Debug
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      print('Register response status: ${response.statusCode}'); // Debug
      print('Register response body: ${response.body}'); // Debug

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'auth_token', value: data['token']);
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Register error: $e'); // Debug
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        print('⚠️ No token found');
        return null; // 👈 no lanzamos excepción
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/v1/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5)); // 👈 evita cuelgue por red

      print('getCurrentUser status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('⚠️ Error getting user: ${response.body}');
        return null; // 👈 devolvemos null en vez de lanzar
      }
    } catch (e) {
      print('❌ getCurrentUser error: $e');
      return null; // 👈 no propagamos error
    }
  }


  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
  }
}
