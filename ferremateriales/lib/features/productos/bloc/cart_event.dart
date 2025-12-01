import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final int productId;
  AddToCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class RemoveFromCart extends CartEvent {
  final int id;
  RemoveFromCart(this.id);

  @override
  List<Object?> get props => [id];
}

class IncreaseQuantity extends CartEvent {
  final int id;
  IncreaseQuantity(this.id);

  @override
  List<Object?> get props => [id];
}

class DecreaseQuantity extends CartEvent {
  final int id;
  DecreaseQuantity(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearCart extends CartEvent {}
