import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final Map<String, dynamic> product;
  AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final String name;
  RemoveFromCart(this.name);

  @override
  List<Object?> get props => [name];
}

class IncreaseQuantity extends CartEvent {
  final String name;
  IncreaseQuantity(this.name);

  @override
  List<Object?> get props => [name];
}

class DecreaseQuantity extends CartEvent {
  final String name;
  DecreaseQuantity(this.name);

  @override
  List<Object?> get props => [name];
}

/// 🗑 Evento nuevo para vaciar todo el carrito
class ClearCart extends CartEvent {}
