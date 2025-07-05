import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    // lista de usuarios registrados en memoria
    final List<Map<String, String>> _registeredUsers = [
      
    ];

    // login
    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      await Future.delayed(const Duration(seconds: 1));

      final userFound = _registeredUsers.firstWhere(
        (user) =>
            user['email'] == event.email && user['password'] == event.password,
        orElse: () => {},
      );

      if (userFound.isNotEmpty) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(
            status: AuthStatus.failure, error: 'Credenciales incorrectas'));
      }
    });

    // logout
    on<LogoutRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.initial));
    });

    // registro
    on<RegisterRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      await Future.delayed(const Duration(seconds: 1));

      final existingUser = _registeredUsers.any((user) => user['email'] == event.email);

      if (existingUser) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: 'El usuario ya existe',
        ));
      } else {
        _registeredUsers.add({
          'email': event.email,
          'password': event.password,
        });
        emit(state.copyWith(status: AuthStatus.success));
      }
    });
  }
}
