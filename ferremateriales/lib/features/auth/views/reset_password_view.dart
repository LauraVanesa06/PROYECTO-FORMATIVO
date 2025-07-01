import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class ResetPasswordView extends StatefulWidget {
  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _email = value,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Campo requerido"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Enviar recuperación"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                          ResetPasswordRequested(email: _email),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solicitud enviada")),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
