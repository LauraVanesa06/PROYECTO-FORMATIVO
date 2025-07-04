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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: Colors.orange),
              hintText: 'Usuario',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(    // <--- aquí
              borderSide: const BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            ),
            onChanged: (value) => _username = value,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 14),

          // Campo de contraseña con íconos
          TextFormField(
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock, color: Colors.orange),
              hintText: 'Contraseña',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
                focusedBorder: OutlineInputBorder(    // <--- aquí
                borderSide: const BorderSide(color: Colors.orange),                  borderRadius: BorderRadius.circular(12),
              ),

              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.orange,
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
          const SizedBox(height: 14),

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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,  
                
              ),
              child: const Text(
                "Iniciar sesión",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
