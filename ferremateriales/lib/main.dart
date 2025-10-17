import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'features/productos/bloc/cart_bloc.dart';
import 'features/productos/bloc/product_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/productos/cubit/theme_cubit.dart';
import 'features/auth/views/login_view.dart';
import 'features/productos/views/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Evita errores visuales en producción
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
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeState.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            locale: themeState.locale,
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                switch (authState.status) {
                  case AuthStatus.success:
                  case AuthStatus.guest:
                    return MainView();

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
          );
        },
      ),
    );
  }
}
