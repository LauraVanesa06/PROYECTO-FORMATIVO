import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(
          ThemeState(
            isDarkMode: false,
            locale: Locale('es'),
          ),
        );

  void toggleTheme() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void changeLanguage(Locale newLocale) {
    emit(state.copyWith(locale: newLocale));
  }
}
