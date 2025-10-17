import 'package:equatable/equatable.dart';

// Clase base de todos los eventos de autenticación
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// iniciar comprobación de sesión al arrancar la app
class AuthStarted extends AuthEvent {}

// iniciar sesión con correo y contraseña
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// cerrar sesión
class LogoutRequested extends AuthEvent {}

// restablecer contraseña
class ResetPasswordRequested extends AuthEvent {
  final String email;

  ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// registrar nuevo usuario
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombre;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.nombre,
  });

  @override
  List<Object> get props => [email, password, nombre];
}

// actualizar datos del usuario (nombre / email)
class UpdateUserRequested extends AuthEvent {
  final String nombre;
  final String email;

  UpdateUserRequested({required this.nombre, required this.email});

  @override
  List<Object> get props => [nombre, email];
}

// continuar como invitado
class ContinueAsGuest extends AuthEvent {}
