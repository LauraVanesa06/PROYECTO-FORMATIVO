import 'package:equatable/equatable.dart';

/// Define los posibles estados de autenticación
enum AuthStatus {
  initial,    // Cuando arranca la app
  loading,    // Cuando está procesando (login, registro, etc.)
  success,    // Login exitoso
  failure,    // Fallo en autenticación
  loggedOut,  // Cuando el usuario cierra sesión
  guest,      // Usuario invitado
  authenticated,
  resetPasswordSent,  // Código de verificación enviado
  resetPasswordError, // Error al enviar código
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  final String? nombre;
  final String? email;
  final String? resetMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.nombre,
    this.email,
    this.resetMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? nombre,
    String? email,
    String? resetMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      // Reiniciar error si el estado es exitoso, logout o invitado
      error: (status == AuthStatus.success ||
              status == AuthStatus.loggedOut ||
              status == AuthStatus.guest ||
              status == AuthStatus.resetPasswordSent)
          ? null
          : error ?? this.error,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      resetMessage: resetMessage ?? this.resetMessage,
    );
  }

  @override
  List<Object?> get props => [status, error, nombre, email, resetMessage];
}
