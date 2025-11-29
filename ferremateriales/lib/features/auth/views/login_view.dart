import 'package:ferremateriales/features/auth/bloc/auth_bloc.dart';
import 'package:ferremateriales/features/auth/bloc/auth_event.dart';
import 'package:ferremateriales/features/auth/bloc/auth_state.dart';
import 'package:ferremateriales/features/auth/views/register_view.dart';
import 'package:ferremateriales/features/auth/widgets/login_form.dart';
import 'package:ferremateriales/features/productos/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Inicio de sesión exitoso',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
            ),
          );
          // Pequeño delay para asegurar que el estado se actualice
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => MainView()),
              );
            }
          });
        } else if (state.status == AuthStatus.guest) {
          // Redirigir al MainView cuando continúa como invitado
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainView()),
          );
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error ?? 'Error de autenticación',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => MainView()),
                );
              },
            ),
          ),
          body: Stack(
            children: [
              // Contenido principal
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo circular
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2e67a3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Inicia sesión',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Contenedor del formulario
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Formulario
                              LoginForm(),
                              const SizedBox(height: 24),

                              // Separador
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      '¿Necesitas ayuda?',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Enlaces
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '¿No tienes cuenta?',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => RegisterView()),
                                      );
                                    },
                                    child: const Text(
                                      'Regístrate aquí',
                                      style: TextStyle(
                                        color: Color(0xFF2e67a3),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // 🔹 Botón de Continuar como invitado (dentro del contenedor)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(ContinueAsGuest());
                                  },
                                  icon: const Icon(Icons.person_outline, color: Colors.white),
                                  label: const Text(
                                    'Continuar como invitado',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2e67a3),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Loader
              if (state.status == AuthStatus.loading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5687ba),
                      strokeWidth: 4,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
