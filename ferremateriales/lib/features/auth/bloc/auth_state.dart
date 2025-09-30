import 'package:equatable/equatable.dart';

/// Define los posibles estados de autenticación
enum AuthStatus {
  initial,    // Cuando arranca la app
  loading,    // Cuando está procesando (login, registro, etc.)
  success,    // Login exitoso
  failure,    // Fallo en autenticación
  loggedOut,  // Cuando el usuario cierra sesión
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  final String? nombre; 

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.nombre,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? nombre,
  }) {
    return AuthState(
      status: status ?? this.status,
      // Limpiar error si el estado es success o loggedOut
      error: (status == AuthStatus.success || status == AuthStatus.loggedOut)
          ? null
          : error ?? this.error,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  List<Object?> get props => [status, error, nombre];
}
