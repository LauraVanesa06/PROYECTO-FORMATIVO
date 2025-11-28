import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ferremateriales/core/config/api_config.dart';
import 'firebase_options.dart';
import 'features/productos/bloc/cart_bloc.dart';
import 'features/productos/bloc/product_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/productos/cubit/theme_cubit.dart';
import 'features/auth/views/login_view.dart';
import 'features/productos/views/main_view.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();

  ErrorWidget.builder = (FlutterErrorDetails details) => const SizedBox.shrink();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            AuthService(baseUrl: ApiConfig.baseUrl),
          )..add(AuthStarted()),
        ),
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => ThemeCubit(prefs)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeState.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            locale: themeState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            home: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                print('Main - Estado de auth: ${state.status}');
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) {
                  // Reconstruir solo cuando el status cambia significativamente
                  print('Main - buildWhen: ${previous.status} -> ${current.status}');
                  return previous.status != current.status && 
                         current.status != AuthStatus.loading;
                },
                builder: (context, authState) {
                  print('Main - Construyendo con estado: ${authState.status}');
                  
                  if (authState.status == AuthStatus.success || 
                      authState.status == AuthStatus.guest) {
                    return MainView();
                  }
                  
                  return const LoginView();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
