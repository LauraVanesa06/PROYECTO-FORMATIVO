import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text("Tema oscuro"),
                value: state.isDarkMode,
                onChanged: (_) => themeCubit.toggleTheme(),
              ),
              ListTile(
                title: const Text("Idioma"),
                trailing: DropdownButton<Locale>(
                  value: state.locale,
                  items: const [
                    DropdownMenuItem(
                      value: Locale('es'),
                      child: Text("Español"),
                    ),
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text("Inglés"),
                    ),
                  ],
                  onChanged: (locale) {
                    if (locale != null) {
                      themeCubit.changeLanguage(locale);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
