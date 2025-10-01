  final nombreController = TextEditingController(text: nombre);
  final emailController = TextEditingController(text: email);
import 'package:flutter/material.dart';

class AcountView extends StatelessWidget {
  final String nombre;
  final String email;

  const AcountView({
    super.key,
    required this.nombre,
    required this.email,
  });

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
                subtitle: Text(nombre),
              ),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(email),
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