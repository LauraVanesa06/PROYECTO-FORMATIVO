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

  // Verificar si el correo existe y enviar código de recuperación usando Devise
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      print('Requesting password reset for email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user': {
            'email': email,
          }
        }),
      );

      print('Password reset response status: ${response.statusCode}');
      print('Password reset response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Devise devuelve 200 y puede o no devolver JSON
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Instrucciones de recuperación enviadas a tu correo',
          'reset_token': data['reset_token'], // Token para validar
        };
      } else if (response.statusCode == 404) {
        // Correo no encontrado
        throw Exception('Este correo no está registrado');
      } else if (response.statusCode == 422) {
        // Error de validación
        try {
          final errorData = jsonDecode(response.body);
          String errorMsg = 'Correo electrónico inválido';
          if (errorData['errors'] != null) {
            if (errorData['errors'] is List) {
              errorMsg = errorData['errors'].join(', ');
            } else if (errorData['errors'] is Map) {
              errorMsg = errorData['errors'].values.first.toString();
            }
          } else if (errorData['error'] != null) {
            errorMsg = errorData['error'];
          }
          throw Exception(errorMsg);
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Correo electrónico inválido');
        }
      } else {
        throw Exception('Error al procesar la solicitud');
      }
    } catch (e) {
      print('Error in requestPasswordReset: $e');
      rethrow;
    }
  }

  // Actualizar información del usuario
  Future<Map<String, dynamic>> updateUser({
    required String nombre,
    required String email,
  }) async {
    try {
      final token = await storage.read(key: 'auth_token');
      
      if (token == null) {
        throw Exception('No estás autenticado');
      }

      print('Updating user with name: $nombre, email: $email');
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/auth/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': nombre,
          'email': email,
        }),
      );

      print('Update user response status: ${response.statusCode}');
      print('Update user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error de validación');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar información');
      }
    } catch (e) {
      print('Error in updateUser: $e');
      rethrow;
    }
  }

  // Cambiar contraseña con código de recuperación
  Future<Map<String, dynamic>> changePasswordWithCode({
    required String email,
    required String recoveryCode,
    required String newPassword,
  }) async {
    try {
      print('Changing password for email: $email with code: $recoveryCode');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user': {
            'email': email,
            'recovery_code': recoveryCode,
            'password': newPassword,
            'password_confirmation': newPassword,
          }
        }),
      );

      print('Change password response status: ${response.statusCode}');
      print('Change password response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Contraseña cambiada exitosamente',
        };
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? errorData['message'] ?? 'Código inválido o expirado');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error al cambiar la contraseña');
      }
    } catch (e) {
      print('Error in changePasswordWithCode: $e');
      rethrow;
    }
  }

  // Cambiar contraseña desde la cuenta (con contraseña actual)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await storage.read(key: 'auth_token');
      
      if (token == null) {
        throw Exception('No estás autenticado');
      }

      print('Changing password from account');
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      print('Change password response status: ${response.statusCode}');
      print('Change password response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Contraseña actualizada correctamente',
        };
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Contraseña actual incorrecta');
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'La nueva contraseña no cumple los requisitos');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al cambiar la contraseña');
      }
    } catch (e) {
      print('Error in changePassword: $e');
      rethrow;
    }
  }
}

