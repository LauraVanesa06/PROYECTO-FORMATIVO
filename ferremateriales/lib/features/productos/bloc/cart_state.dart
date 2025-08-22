import 'package:equatable/equatable.dart';

class CartState extends Equatable {
  final List<Map<String, dynamic>> items;

  const CartState({this.items = const []});

  /// 👉 Calcula el total automáticamente (double para más precisión)
  double get total {
    return items.fold(0.0, (sum, item) {
      final price = (item["price"] ?? 0).toDouble();
      final quantity = (item["quantity"] ?? 1) as int;
      return sum + (price * quantity);
    });
  }

  /// 👉 Saber si el carrito está vacío
  bool get isEmpty => items.isEmpty;

  /// 👉 Cantidad total de productos
  int get totalItems {
    return items.fold(0, (sum, item) {
      final quantity = (item["quantity"] ?? 1) as int;
      return sum + quantity;
    });
  }

  /// 👉 Permite copiar el estado con nuevos valores
  CartState copyWith({List<Map<String, dynamic>>? items}) {
    return CartState(
      items: items ?? this.items,
    );
  }

  @override
  List<Object> get props => [items];
}
