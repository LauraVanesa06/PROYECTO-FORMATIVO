part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductEntrarPressed extends ProductEvent {}

class ToggleFavorite extends ProductEvent {
  final int productId;
  const ToggleFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductFilterByCategory extends ProductEvent {
  final String categoryName;

  ProductFilterByCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}
