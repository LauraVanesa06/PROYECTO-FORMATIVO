import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    // LOGIN
    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      await Future.delayed(const Duration(seconds: 1)); // simulación de red

      if (event.email == 'usuario@test.com' && event.password == '1234') {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: 'Credenciales incorrectas',
        ));
      }
    });

    // LOGOUT
    on<LogoutRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.initial));
    });

    // RESET PASSWORD
    on<ResetPasswordRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      await Future.delayed(const Duration(seconds: 1)); // simulación de red
      // puedes validar si existe el correo aquí
      emit(state.copyWith(
        status: AuthStatus.success,
      ));
    });
  }
}
