part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductEntrarPressed extends ProductEvent {}

class ProductRefrescar extends ProductEvent {} // 👈 NUEVO EVENTO

class ProductFilterByCategory extends ProductEvent {
  final String categoryName;

  const ProductFilterByCategory(this.categoryName);

  @override
  List<Object?> get props => [categoryName];
}

class ToggleFavorite extends ProductEvent {
  final int productId;

  const ToggleFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}
