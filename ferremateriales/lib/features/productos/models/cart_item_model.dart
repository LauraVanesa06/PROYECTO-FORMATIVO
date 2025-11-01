import 'package:ferremateriales/features/productos/model/product_model.dart';

class CartItemModel {
  final int id;
  final int quantity;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      product: ProductModel.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'product': product.toJson(),
    };
  }
}
