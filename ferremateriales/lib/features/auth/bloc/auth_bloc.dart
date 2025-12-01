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
          emit(
            state.copyWith(
              status: AuthStatus.success,
              nombre: user['name'],
              email: user['email'],
            ),
          );
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
          emit(
            state.copyWith(
              status: AuthStatus.success,
              email: response['user']['email'],
              nombre: response['user']['name'],
            ),
          );
          print('Login exitoso'); // Debug
        } else {
          throw Exception('Token no encontrado');
        }
      } catch (e) {
        print('Error en login: $e'); // Debug
        // Extraer el mensaje de error específico
        String errorMessage = 'Error de autenticación';
        if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceAll('Exception:', '').trim();
        }
        emit(state.copyWith(status: AuthStatus.failure, error: errorMessage));
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
        emit(
          state.copyWith(
            status: AuthStatus.success,
            nombre: response['user']['name'],
            email: response['user']['email'],
          ),
        );
      } catch (e) {
        print('🔴 Register error en bloc: $e'); // Debug
        // Extraer el mensaje de error específico
        String errorMessage = 'Error al registrar usuario';
        if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceAll('Exception:', '').trim();
        } else {
          errorMessage = e.toString();
        }
        print('🔴 Error message extraído: $errorMessage'); // Debug
        emit(state.copyWith(status: AuthStatus.failure, error: errorMessage));
      }
    });

    // Continuar como invitado
    on<ContinueAsGuest>((event, emit) async {
      await _authService.logout();
      emit(const AuthState(status: AuthStatus.loggedOut));
      print('👤 Continuar como invitado');
      emit(
        state.copyWith(status: AuthStatus.guest, nombre: 'Invitado', email: ''),
      );
    });

    // Cerrar sesión
    on<LogoutRequested>((event, emit) async {
      await _authService.logout();
      emit(const AuthState(status: AuthStatus.loggedOut));
    });

    // Solicitar restablecimiento de contraseña
    on<ResetPasswordRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        final response = await _authService.requestPasswordReset(event.email);
        emit(
          state.copyWith(
            status: AuthStatus.resetPasswordSent,
            resetMessage: response['message'],
            resetToken: response['reset_token'], // Guardar el token
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: AuthStatus.resetPasswordError,
            error: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    });

    // Actualizar información del usuario
    on<UpdateUserRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        final response = await _authService.updateUser(
          nombre: event.nombre,
          email: event.email,
        );
        emit(
          state.copyWith(
            status: AuthStatus.success,
            nombre: response['user']['name'],
            email: response['user']['email'],
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            error: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    });

    // Cambiar contraseña con código de recuperación
    on<ChangePasswordRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        await _authService.changePasswordWithCode(
          email: event.email,
          recoveryCode: event.recoveryCode,
          newPassword: event.newPassword,
        );
        emit(state.copyWith(status: AuthStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            error: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    });

    // Cambiar contraseña desde la cuenta
    on<ChangePasswordFromAccountRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        await _authService.changePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        emit(state.copyWith(status: AuthStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            error: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    });
  }
}
