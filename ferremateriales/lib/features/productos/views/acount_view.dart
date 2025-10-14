import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class AcountView extends StatefulWidget {
  final String nombre;
  final String email;

  const AcountView({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<AcountView> createState() => _AcountViewState();
}

class _AcountViewState extends State<AcountView> {
  late TextEditingController nombreController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombre);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta')),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Datos personales'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            children: [
              ListTile(
                title: const Text('Nombre'),
                subtitle: Text(widget.nombre),
              ),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(widget.email),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.deepPurple),
                title: const Text('Editar datos'),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Editar datos personales'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nombreController,
                            decoration: const InputDecoration(labelText: 'Nombre'),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Correo'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              UpdateUserRequested(
                                nombre: nombreController.text,
                                email: emailController.text,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
