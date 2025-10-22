import 'package:ferremateriales/l10n/app_localizations.dart';
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
    final I10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(I10n.account)),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text(I10n.personalinformation),
            trailing: const Icon(Icons.keyboard_arrow_right),
            children: [
              ListTile(
                title:  Text(I10n.name),
                subtitle: Text(widget.nombre),
              ),
              ListTile(
                title: Text(I10n.email),
                subtitle: Text(widget.email),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.deepPurple),
                title: Text(I10n.modifyinformation),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(I10n.modifyinformation),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nombreController,
                            decoration: InputDecoration(labelText: I10n.name),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: I10n.email),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(I10n.cancel),
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
                          child: Text(I10n.save),
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
