import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    context.read<AuthBloc>().add(LoginSubmitted(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Correo')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
            SizedBox(height: 16),
            if (state.status == AuthStatus.loading)
              CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _submit, child: Text('Iniciar sesión')),
            if (state.status == AuthStatus.failure)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(state.error ?? '', style: TextStyle(color: Colors.red)),
              )
          ],
        );
      },
    );
  }
}
