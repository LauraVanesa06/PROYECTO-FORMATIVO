import 'package:ferremateriales/features/auth/bloc/auth_event.dart';
import 'package:ferremateriales/features/auth/bloc/auth_state.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/views/login_view.dart';
import 'acount_view.dart';
import 'config_view.dart';

class ProfileView extends StatelessWidget {
  final String userName;
  final String? userPhotoUrl;

  const ProfileView({super.key, this.userName = "", this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    final I10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == AuthStatus.loggedOut,
      listener: (context, state) {
        // 🔹 Cuando el estado cambia a "loggedOut", redirigimos al login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(I10n.profile),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade200,
              backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                  ? NetworkImage(userPhotoUrl!)
                  : null,
              child: (userPhotoUrl == null || userPhotoUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 15),
            Text(
              userName.isNotEmpty ? userName : "Usuario",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.account_circle, color: Colors.deepPurple),
                    title: Text(I10n.account),
                    onTap: () {
                      final authState = context.read<AuthBloc>().state;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcountView(
                            nombre: authState.nombre ?? "",
                            email: authState.email ?? "",
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.settings, color: Colors.deepPurple),
                    title: Text(I10n.settings),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConfigView()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(I10n.logout),
                    onTap: () {
                      // 🔹 Dispara el evento de logout
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}
