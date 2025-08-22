import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/productos/bloc/cart_bloc.dart';
import 'firebase_options.dart';
import 'features/productos/bloc/product_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/views/login_view.dart';
import 'features/productos/views/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 👇 Ocultar errores visuales rojos (como overflow)
  ErrorWidget.builder = (FlutterErrorDetails details) => const SizedBox.shrink();

  runApp(const FerreteriaApp());
}

class FerreteriaApp extends StatelessWidget {
  const FerreteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthStarted())),
        BlocProvider(create: (_) => CartBloc()),       // 👈 Ahora el carrito está disponible en toda la app
        BlocProvider(create: (_) => ProductBloc()),    // 👈 También los productos
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
            bodySmall: TextStyle(color: Colors.black),
            titleLarge: TextStyle(color: Colors.black),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromARGB(255, 250, 247, 247),
            selectedItemColor: Color.fromARGB(255, 2, 2, 2),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            switch (authState.status) {
              case AuthStatus.success:
                return const MainView(); // 👈 Aquí ya tienes acceso al carrito
              case AuthStatus.failure:
              case AuthStatus.loggedOut:
                return LoginView();
              default:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
            }
          },
        ),
      ),
    );
  }
}