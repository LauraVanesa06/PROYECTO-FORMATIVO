import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import 'register_view.dart';
import 'reset_password_view.dart';
import '../../productos/views/main_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        print('Estado actual: ${state.status}');

        if (state.status == AuthStatus.success) {
          print('Redirigiendo a MainView');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainView()),
          );
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Error de autenticación')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/degrade.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: state.status == AuthStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.orange,
                            radius: 40,
                            child: Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            l10n.login,
                            style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 219, 222, 227),
                            ),
                          ),

                          const SizedBox(height: 30),

                          LoginForm(),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RegisterView()),
                              );
                            },
                            child: Text(
                              l10n.noAccount,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ResetPasswordView()),
                              );
                            },
                            child: Text(
                              l10n.forgotPassword,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(ContinueAsGuest());
                            },
                            icon: const Icon(Icons.person_outline, color: Colors.white),
                            label: const Text(
                              "Continuar como invitado",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
