import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs)
      : super(
          ThemeState(
            isDarkMode: _prefs.getBool('isDarkMode') ?? false,
            locale: Locale(_prefs.getString('language') ?? 'es'),
          ),
        );

  Future<void> toggleTheme() async {
    final newValue = !state.isDarkMode;
    await _prefs.setBool('isDarkMode', newValue);
    emit(state.copyWith(isDarkMode: newValue));
  }

  Future<void> changeLanguage(Locale locale) async {
    await _prefs.setString('language', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  // Restablecer tema al modo claro (para cuando se cierra sesión)
  Future<void> resetTheme() async {
    await _prefs.setBool('isDarkMode', false);
    emit(state.copyWith(isDarkMode: false));
  }
}
