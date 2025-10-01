import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
    on<UpdateUserRequested>((event, emit) async {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(event.nombre);
        await user.updateEmail(event.email);
        emit(state.copyWith(nombre: event.nombre, email: event.email));
      }
    });
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(const AuthState()) {
    // Cuando inicia la app
    on<AuthStarted>((event, emit) async {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.success,
          nombre: user.displayName ?? '',
          email: user.email ?? '',
        ));
      } else {
        emit(const AuthState(status: AuthStatus.loggedOut));
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
        final user = _firebaseAuth.currentUser;
        emit(state.copyWith(
          status: AuthStatus.success,
          nombre: user?.displayName ?? '',
          email: event.email,
        ));
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
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        await userCredential.user!.updateDisplayName(event.nombre);
        emit(state.copyWith(
          status: AuthStatus.success,
          nombre: event.nombre,
          email: event.email,
        ));
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: e.message ?? "Error al registrar",
          nombre: event.nombre,
          email: event.email,
        ));
      }
    });
  }
}
