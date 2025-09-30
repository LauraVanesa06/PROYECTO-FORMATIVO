import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombre;

  RegisterRequested({required this.email, required this.password, required this.nombre});

  @override
  List<Object> get props => [email, password, nombre];
}
