import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      await Future.delayed(const Duration(seconds: 1)); // Simula red

      // Simulamos autenticación simple
      if (event.email == 'usuario@test.com' && event.password == '1234') {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(status: AuthStatus.failure, error: 'Credenciales incorrectas'));
      }
      on<LogoutRequested>((event, emit) async {
  // Aquí puedes limpiar tokens, etc., si es necesario
  emit(AuthState(status: AuthStatus.initial));
});
  

    });
  }
}
