import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import '../utils/email_validator.dart';
import '../utils/password_validator.dart';
import '../../productos/views/main_view.dart';

class RegisterView extends StatefulWidget {
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _nombre = "";
  String _email = "";
  String _password = "";
  String? _emailError;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario registrado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Redirigir al MainView después del registro exitoso
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainView()),
          );
        } else if (state.status == AuthStatus.failure) {
          print('🔴 Error en registro: ${state.error}'); // Debug
          
          // Verificar si el error es de email duplicado
          if (state.error != null && 
              (state.error!.contains('DUPLICATE_EMAIL') ||
               state.error!.contains('ya está registrado') || 
               state.error!.contains('already exists') ||
               state.error!.contains('already registered') ||
               state.error!.contains('duplicado') ||
               (state.error!.toLowerCase().contains('email') && state.error!.toLowerCase().contains('taken')))) {
            // Marcar error en el campo de email
            setState(() {
              _emailError = 'Este correo electrónico ya está registrado';
            });
            // Revalidar el formulario para mostrar el error en rojo
            _formKey.currentState?.validate();
          }
          
          // Mostrar UN SOLO SnackBar con el mensaje específico
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error ?? 'Error desconocido',
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo circular simple
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
                        Icons.person_add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Registrarse',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre
                            TextFormField(
                              style: GoogleFonts.inter(
                                color: const Color(0xFF222222),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nombre completo',
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
                              onChanged: (value) => _nombre = value,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Este campo es requerido' : null,
                            ),
                            const SizedBox(height: 24),

                            // Email
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
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                ),
                                focusedErrorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                setState(() {
                                  _email = value;
                                  // Limpiar error al escribir
                                  if (_emailError != null) {
                                    _emailError = null;
                                  }
                                });
                              },
                              validator: (value) {
                                // Si hay un error de email duplicado, mostrarlo
                                if (_emailError != null) {
                                  return _emailError;
                                }
                                // Si no, validar formato normal
                                return EmailValidator.validate(value);
                              },
                            ),
                            
                            // Mensaje adicional si el email está duplicado
                            if (_emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Intenta iniciar sesión o usa otro correo',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Contraseña
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
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
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
                              onChanged: (value) {
                                setState(() {
                                  _password = value;
                                });
                              },
                              validator: PasswordValidator.validate,
                            ),
                            const SizedBox(height: 12),

                            // Indicador de fortaleza de contraseña
                            if (_password.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: PasswordValidator.getStrength(_password) / 100,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(PasswordValidator.getStrengthColor(
                                              PasswordValidator.getStrength(_password),
                                            )),
                                          ),
                                          minHeight: 4,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        PasswordValidator.getStrengthText(
                                          PasswordValidator.getStrength(_password),
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Color(PasswordValidator.getStrengthColor(
                                            PasswordValidator.getStrength(_password),
                                          )),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),

                            // Confirmar contraseña
                            TextFormField(
                              obscureText: _obscurePassword,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF222222),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Confirmar contraseña',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Debes confirmar tu contraseña';
                                }
                                if (value != _password) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Botón de registro
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      RegisterRequested(
                                        email: _email,
                                        password: _password,
                                        nombre: _nombre,
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
                                  'Registrarse',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Separador
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '¿Ya tienes cuenta?',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Link a login
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Inicia sesión aquí',
                                  style: TextStyle(
                                    color: Color(0xFF2e67a3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
