import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(const AuthState()) {
    // Cuando inicia la app
    on<AuthStarted>((event, emit) async {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(const AuthState(status: AuthStatus.loggedOut)); // ✅ CAMBIO CLAVE
      }
    });

    // Cuando se envía el formulario de login
    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(state.copyWith(status: AuthStatus.success));
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: e.message ?? "Credenciales incorrectas",
        ));
      }
    });

    // Cuando se solicita el logout
    on<LogoutRequested>((event, emit) async {
      await _firebaseAuth.signOut();
      emit(const AuthState(status: AuthStatus.loggedOut));
    });

    // Cuando se registra un nuevo usuario
    on<RegisterRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(state.copyWith(status: AuthStatus.success));
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: e.message ?? "Error al registrar",
        ));
      }
    });
  }
}
