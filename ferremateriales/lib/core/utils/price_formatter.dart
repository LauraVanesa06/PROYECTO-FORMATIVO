import 'package:intl/intl.dart';

class PriceFormatter {
  /// Formatea un precio con separadores de miles y sin decimales
  /// Ejemplo: 2960 -> "$2.960"
  static String format(dynamic price) {
    if (price == null) return '\$0';
    
    final numPrice = price is double ? price : double.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,###', 'es_CO');
    return '\$${formatter.format(numPrice.toInt())}';
  }

  /// Formatea un precio con COP y separadores de miles
  /// Ejemplo: 2960 -> "COP $2.960"
  static String formatWithCurrency(dynamic price) {
    if (price == null) return 'COP \$0';
    
    final numPrice = price is double ? price : double.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,###', 'es_CO');
    return 'COP \$${formatter.format(numPrice.toInt())}';
  }

  /// Formatea solo el número sin símbolo de moneda
  /// Ejemplo: 2960 -> "2.960"
  static String formatNumber(dynamic price) {
    if (price == null) return '0';
    
    final numPrice = price is double ? price : double.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,###', 'es_CO');
    return formatter.format(numPrice.toInt());
  }
}
