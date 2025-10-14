part of 'theme_cubit.dart';

@immutable
class ThemeState {
  final bool isDarkMode;
  final Locale locale;

  const ThemeState({
    required this.isDarkMode,
    required this.locale,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    Locale? locale,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
    );
  }
}

class ThemeInitial extends ThemeState {
  ThemeInitial() : super(isDarkMode: false, locale: Locale('es'));
}
