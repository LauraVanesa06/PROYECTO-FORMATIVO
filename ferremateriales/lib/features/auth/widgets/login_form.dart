import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../utils/email_validator.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de correo electrónico minimalista
          TextFormField(
            style: GoogleFonts.inter(
              color: const Color(0xFF222222),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Correo electrónico',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 2),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2e67a3), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => _username = value,
            validator: EmailValidator.validate,
          ),
          const SizedBox(height: 24),

          // Campo de contraseña minimalista
          TextFormField(
            obscureText: _obscurePassword,
            style: GoogleFonts.inter(
              color: const Color(0xFF222222),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 2),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2e67a3), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                  size: 20,
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
                value == null || value.isEmpty ? 'Este campo es requerido' : null,
          ),
          const SizedBox(height: 16),

          // Recordarme
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF2e67a3),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recordarme',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botón de login con estilo redondeado del backend
          SizedBox(
            width: double.infinity,
            height: 50,
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
                backgroundColor: const Color(0xFF2e67a3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF2e67a3).withOpacity(0.3),
              ),
              child: Text(
                'Entrar',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}