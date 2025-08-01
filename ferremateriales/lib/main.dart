import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/views/login_view.dart';
import 'features/productos/views/main_view.dart'; // MainView ya existe

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Ferreteria());
}

class Ferreteria extends StatelessWidget {
  const Ferreteria({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthStarted())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState.status == AuthStatus.initial ||
                authState.status == AuthStatus.failure ||
                authState.status == AuthStatus.loggedOut) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginView()),
                (route) => false,
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState.status == AuthStatus.success) {
                return const MainView(); // Esto ya muestra la barra inferior y todo
              } else {
                return LoginView();
              }
            },
          ),
        ),
      ),
    );
  }
}
