import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../../productos/views/main_view.dart';
import 'register_view.dart';
import 'reset_password_view.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.status == AuthStatus.success,
      listener: (context, state) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainView()),
        );
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/degrade.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo usuario
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 40,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),

                  // título
                  Text(
                    'Inicia sesión para continuar',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 219, 222, 227),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 10),
                  // Text(
                  //   'Inicia sesión para continuar',
                  //   style: GoogleFonts.montserrat(
                  //     fontSize: 16,
                  //     color: Colors.grey[200], // más contraste con fondo oscuro
                  //   ),
                  // ),
                  const SizedBox(height: 30),

                  // LoginForm sin tarjeta
                  LoginForm(),

                  const SizedBox(height: 16),

                  // Botón de registrarse
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterView()),
                      );
                    },
                    child: const Text(
                      "¿No tienes cuenta? Regístrate aquí",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  // Botón de olvidar contraseña
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ResetPasswordView()),
                      );
                    },
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
