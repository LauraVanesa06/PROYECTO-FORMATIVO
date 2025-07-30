import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/views/login_view.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/productos/bloc/product_bloc.dart';
import 'features/productos/views/initial_view.dart';
import 'features/productos/views/products_view.dart';



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
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProductBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocListener<AuthBloc, AuthState>(
  listener: (context, authState) {
    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.failure) {
      // Cierra sesión y navega a LoginView limpiando el historial
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) =>  LoginView()),
        (route) => false,
      );
    }
  },
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, authState) {
      if (authState.status == AuthStatus.success) {
        return BlocListener<ProductBloc, ProductState>(
          listener: (context, productState) {
            if (productState is ProductLoadSuccess) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductsPageView()),
              );
            } else if (productState is ProductLoadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al cargar productos')),
              );
            }
          },
          child: const InitialView(), // botones: productos / contactos
        );
      } else {
        return  LoginView();
      }
    },
  ),
),

      ),
    );
  }
}