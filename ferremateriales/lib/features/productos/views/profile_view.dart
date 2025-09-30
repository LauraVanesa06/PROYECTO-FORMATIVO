import 'package:flutter/material.dart';

import '../../auth/views/login_view.dart';

class ProfileView extends StatelessWidget {
  final String userName;

  const ProfileView({super.key, this.userName = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade200,
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 15),
          // Nombre del usuario
          Text(
            userName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          // Opciones
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle, color: Colors.deepPurple),
                  title: const Text("Cuenta"),
                  onTap: () {
                    // Acción para cuenta
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text("Configuración"),
                  onTap: () {
                    // Acción para configuración
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Cerrar sesión"),
                  onTap: () {
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
