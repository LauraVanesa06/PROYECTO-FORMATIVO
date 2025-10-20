import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                title: Text(l10n.darkTheme),
                value: state.isDarkMode,
                onChanged: (_) => themeCubit.toggleTheme(),
              ),
              ListTile(
                title: Text(l10n.language),
                trailing: DropdownButton<Locale>(
                  value: state.locale,
                  items: [
                    DropdownMenuItem(
                      value: const Locale('es'),
                      child: Text(l10n.spanish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.english),
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
