import 'package:equatable/equatable.dart';

/// Define los posibles estados de autenticación
enum AuthStatus {
  initial,    // Cuando arranca la app
  loading,    // Cuando está procesando (login, registro, etc.)
  success,    // Login exitoso
  failure,    // Fallo en autenticación
  loggedOut,  // Cuando el usuario cierra sesión
  guest,      // usuario invitado
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  final String? nombre;
  final String? email;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.nombre,
    this.email,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? nombre,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      // 🔹 Reiniciamos error si el estado es exitoso, logout o invitado
      error: (status == AuthStatus.success ||
              status == AuthStatus.loggedOut ||
              status == AuthStatus.guest)
          ? null
          : error ?? this.error,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [status, error, nombre, email];
}
