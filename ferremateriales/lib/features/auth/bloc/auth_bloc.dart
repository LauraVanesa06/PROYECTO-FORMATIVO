import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(const AuthState()) {
    // Comprobar sesión activa al iniciar la app
    on<AuthStarted>((event, emit) async {
      try {
        final user = await _authService.getCurrentUser();

        if (user != null && user['email'] != null) {
          emit(state.copyWith(
            status: AuthStatus.success,
            nombre: user['name'],
            email: user['email'],
          ));
          print('✅ Sesión activa detectada');
        } else {
          emit(const AuthState(status: AuthStatus.loggedOut));
          print('ℹ️ No hay sesión activa, mostrar login');
        }
      } catch (e) {
        emit(const AuthState(status: AuthStatus.loggedOut));
        print('❌ Error comprobando sesión: $e');
      }
    });


    // Iniciar sesión
    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        print('Iniciando login...'); // Debug
        final response = await _authService.login(event.email, event.password);
        print('Respuesta login: $response'); // Debug

        if (response['token'] != null) {
          emit(state.copyWith(
            status: AuthStatus.success,
            email: response['user']['email'],
            nombre: response['user']['name'],
          ));
          print('Login exitoso'); // Debug
        } else {
          throw Exception('Token no encontrado');
        }
      } catch (e) {
        print('Error en login: $e'); // Debug
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: 'Error de autenticación',
        ));
      }
    });

    // Registrar usuario
    on<RegisterRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        final response = await _authService.register(
          event.nombre,
          event.email,
          event.password,
        );
        emit(state.copyWith(
          status: AuthStatus.success,
          nombre: response['user']['name'],
          email: response['user']['email'],
        ));
      } catch (e) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          error: 'Error al registrar usuario',
        ));
      }
    });

    // Continuar como invitado
    on<ContinueAsGuest>((event, emit) async {
      print('👤 Continuar como invitado');
      emit(state.copyWith(
        status: AuthStatus.guest,
        nombre: 'Invitado',
        email: '',
      ));
    });


    // Cerrar sesión
    on<LogoutRequested>((event, emit) async {
      await _authService.logout();
      emit(const AuthState(status: AuthStatus.loggedOut));
    });
  }
}
