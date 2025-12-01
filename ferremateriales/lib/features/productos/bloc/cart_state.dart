import 'package:equatable/equatable.dart';
import 'package:ferremateriales/features/productos/models/cart_item_model.dart';

class CartState extends Equatable {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  double get total {
    return items.fold(0.0, (sum, item) {
      final price = (item.product.precio ?? 0).toDouble();
      final quantity = item.quantity;
      return sum + (price * quantity);
    });
  }

  bool get isEmpty => items.isEmpty;

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error];
}
