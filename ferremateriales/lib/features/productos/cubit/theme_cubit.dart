import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs)
      : super(
          ThemeState(
            isDarkMode: false,
            locale: Locale(_prefs.getString('language') ?? 'es'),
          ),
        );

  void toggleTheme() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  Future<void> changeLanguage(Locale locale) async {
    await _prefs.setString('language', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
