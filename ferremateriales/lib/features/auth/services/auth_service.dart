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
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
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

        // Manejo de cart_id correctamente
        if (data['user'] != null) {
          if (data['user']['cart_id'] != null) {
            await storage.write(
              key: 'cart_id',
              value: data['user']['cart_id'].toString(),
            );
          } else if (data['user']['cart'] != null &&
              data['user']['cart']['id'] != null) {
            await storage.write(
              key: 'cart_id',
              value: data['user']['cart']['id'].toString(),
            );
          }
        }

        return data;
      } else if (response.statusCode == 401 || response.statusCode == 422) {
        // Manejo mejorado de errores con códigos específicos
        final errorData = jsonDecode(response.body);
        final errorCode = errorData['error_code'];
        final message = errorData['message'] ?? '';

        // Mensajes específicos basados en el código de error del backend
        String errorMessage;
        switch (errorCode) {
          case 'USER_NOT_FOUND':
            errorMessage = 'No existe una cuenta con este correo electrónico';
            break;
          case 'INVALID_PASSWORD':
            errorMessage = 'Contraseña incorrecta';
            break;
          case 'INVALID_EMAIL_FORMAT':
            errorMessage = 'Formato de correo electrónico inválido';
            break;
          case 'MISSING_CREDENTIALS':
            errorMessage = 'Debes ingresar correo y contraseña';
            break;
          default:
            // Buscar palabras clave en el mensaje para dar respuesta más específica
            if (message.toLowerCase().contains('invalid') ||
                message.toLowerCase().contains('credencial')) {
              errorMessage =
                  'Credenciales inválidas. Verifica tu correo y contraseña';
            } else {
              errorMessage =
                  message.isNotEmpty ? message : 'Error al iniciar sesión';
            }
        }

        throw Exception(errorMessage);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error al iniciar sesión. Intenta nuevamente',
        );
      }
    } catch (e) {
      print('Error in login: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('Registering user with email: $email'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print('Register response status: ${response.statusCode}'); // Debug
      print('Register response body: ${response.body}'); // Debug

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'auth_token', value: data['token']);

        // Guardar user_id y cart_id como en el login
        if (data['user'] != null) {
          await storage.write(
            key: 'user_id',
            value: data['user']['id'].toString(),
          );

          // Manejo de cart_id
          if (data['user']['cart_id'] != null) {
            await storage.write(
              key: 'cart_id',
              value: data['user']['cart_id'].toString(),
            );
          } else if (data['user']['cart'] != null &&
              data['user']['cart']['id'] != null) {
            await storage.write(
              key: 'cart_id',
              value: data['user']['cart']['id'].toString(),
            );
          }
        }

        return data;
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        // Manejo mejorado de errores con códigos específicos
        final errorData = jsonDecode(response.body);
        final errorCode = errorData['error_code'];
        final message = errorData['message'] ?? '';
        final errors = errorData['errors'];

        // Mensajes específicos basados en el código de error del backend
        String errorMessage;
        switch (errorCode) {
          case 'EMAIL_ALREADY_EXISTS':
            errorMessage = 'Correo electrónico ya está en uso';
            break;
          case 'PASSWORD_TOO_SHORT':
            errorMessage = 'La contraseña debe tener al menos 6 caracteres';
            break;
          case 'NAME_TOO_SHORT':
            errorMessage = 'El nombre debe tener al menos 2 caracteres';
            break;
          case 'MISSING_FIELDS':
            errorMessage = 'Debes completar todos los campos';
            break;
          default:
            // Buscar palabras clave en el mensaje o en errors
            if (errors != null && errors is List && errors.isNotEmpty) {
              final firstError = errors[0].toString().toLowerCase();
              if (firstError.contains('correo') ||
                  firstError.contains('email') ||
                  firstError.contains('uso')) {
                errorMessage = 'Correo electrónico ya está en uso';
              } else {
                errorMessage = errors[0].toString();
              }
            } else if (message.toLowerCase().contains('email') &&
                (message.toLowerCase().contains('taken') ||
                    message.toLowerCase().contains('uso') ||
                    message.toLowerCase().contains('registrado'))) {
              errorMessage = 'Correo electrónico ya está en uso';
            } else {
              errorMessage =
                  message.isNotEmpty
                      ? message
                      : 'Error de validación en el registro';
            }
        }

        throw Exception(errorMessage);
      } else if (response.statusCode == 409) {
        // Conflicto (usuario ya existe)
        throw Exception('Este correo electrónico ya está registrado');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ??
                errorData['error'] ??
                'Error al registrar usuario. Intenta nuevamente',
          );
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

  Future<void> saveCartId(int id) async {
    await storage.write(key: 'cart_id', value: id.toString());
  }

  Future<int?> getCartId() async {
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
          'user': {'email': email},
        }),
      );

      print('Password reset response status: ${response.statusCode}');
      print('Password reset response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Devise devuelve 200 y puede o no devolver JSON
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              data['message'] ??
              'Instrucciones de recuperación enviadas a tu correo',
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
        body: jsonEncode({'name': nombre, 'email': email}),
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
        throw Exception(
          errorData['message'] ?? 'Error al actualizar información',
        );
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
          },
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
        throw Exception(
          errorData['error'] ??
              errorData['message'] ??
              'Código inválido o expirado',
        );
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
        throw Exception(
          errorData['message'] ??
              'La nueva contraseña no cumple los requisitos',
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error al cambiar la contraseña',
        );
      }
    } catch (e) {
      print('Error in changePassword: $e');
      rethrow;
    }
  }
}
