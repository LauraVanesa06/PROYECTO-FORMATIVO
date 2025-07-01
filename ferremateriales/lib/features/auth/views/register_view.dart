import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterView extends StatefulWidget {
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Variables para capturar los valores
  String _nombre = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              Text(
                'Crea tu cuenta',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14213D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Regístrate para continuar',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // Card con formulario
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Nombre completo
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Color(0xFF14213D)),
                            labelText: 'Nombre completo',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _nombre = value,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        // Correo
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Color(0xFF14213D)),
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _email = value,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        // Contraseña
                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF14213D)),
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF14213D),
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
                        const SizedBox(height: 16),

                        
                        // Confirmar contraseña
                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Color(0xFF14213D)),
                            labelText: 'Confirmar contraseña',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _confirmPassword = value, 
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                            if (value != _password) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Botón registrar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                print('Confirm Password: $_confirmPassword');
                                // Aquí iría la lógica real de registro o evento bloc
                                print('Registrando $_nombre ($_email)');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Usuario registrado correctamente'),
                                  ),
                                );
                                Navigator.pop(context); // volver al login
                              }
                            },
                            child: const Text('Registrarse'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFCA311),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Link para volver al login
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '¿Ya tienes cuenta? Inicia sesión',
                            style: TextStyle(color: Color(0xFF14213D)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
