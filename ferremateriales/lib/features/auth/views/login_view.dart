import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../../productos/views/initial_view.dart'; // tu pantalla principal

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.status == AuthStatus.success,
      listener: (context, state) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => InitialView()),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Iniciar sesión')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}
