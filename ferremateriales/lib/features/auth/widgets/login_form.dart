import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de usuario con ícono
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Usuario',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _username = value,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),

          // Campo de contraseña con íconos
          TextFormField(
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: 'Contraseña',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onChanged: (value) => _password = value,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 20),

          // Botón de login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                        LoginSubmitted(
                          email: _username,
                          password: _password,
                        ),
                      );
                }
              },
              child: const Text("Iniciar sesión"),
            ),
          ),
        ],
      ),
    );
  }
}
