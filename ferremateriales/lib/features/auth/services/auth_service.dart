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

        await storage.write(
          key: 'user_id', 
          value: data['user']['id'].toString(),
        );

        await storage.write(
          key: 'cart_id', 
          value: data['user']['cart_id'].toString(),
          );
          
        return data;
      } else if (response.statusCode == 401) {
        // Credenciales inválidas
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Correo o contraseña incorrectos');
      } else if (response.statusCode == 422) {
        // Error de validación
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Datos de inicio de sesión inválidos');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al iniciar sesión. Intenta nuevamente');
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
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        // Error de validación (email duplicado, contraseña débil, etc.)
        try {
          final errorData = jsonDecode(response.body);
          print('Error 422/400 data: $errorData'); // Debug
          
          // Verificar diferentes formatos de respuesta del backend
          String errorMessage = 'Error de validación en el registro';
          
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
            // Verificar si el mensaje indica email duplicado
            String msgLower = errorMessage.toLowerCase();
            if (msgLower.contains('email') && (msgLower.contains('taken') || 
                msgLower.contains('exists') || msgLower.contains('duplicado') ||
                msgLower.contains('already') || msgLower.contains('registrado'))) {
              errorMessage = 'Este correo electrónico ya está registrado';
            }
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          } else if (errorData['errors'] != null) {
            // Si hay múltiples errores
            if (errorData['errors'] is Map) {
              final errors = errorData['errors'] as Map;
              if (errors['email'] != null) {
                String emailError = errors['email'].toString();
                // Verificar si es error de email duplicado
                if (emailError.toLowerCase().contains('taken') || 
                    emailError.toLowerCase().contains('exists') ||
                    emailError.toLowerCase().contains('already')) {
                  errorMessage = 'Este correo electrónico ya está registrado';
                } else {
                  errorMessage = emailError;
                }
              } else {
                errorMessage = errors.values.first.toString();
              }
            }
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Error de validación en el registro');
        }
      } else if (response.statusCode == 409) {
        // Conflicto (usuario ya existe)
        throw Exception('Este correo electrónico ya está registrado');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? errorData['error'] ?? 'Error al registrar usuario. Intenta nuevamente');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Error al registrar usuario. Intenta nuevamente');
        }
      }
    } catch (e) {
      print('Register error: $e'); // Debug
      rethrow;
    }
  }

  Future<void> saveCartId(int id) async{
    await storage.write(key: 'cart_id', value: id.toString());
  }

  Future<int?> getCartId() async{
    final value = await storage.read(key: 'cart_id');
    return value != null ? int.tryParse(value) : null;
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
