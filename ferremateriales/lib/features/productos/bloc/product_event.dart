part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductEntrarPressed extends ProductEvent {}

class ProductRefrescar extends ProductEvent {} // 👈 NUEVO EVENTO

class ProductFilterByCategory extends ProductEvent {
  final int categoryId; // ✅ solo ID

  const ProductFilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ToggleFavorite extends ProductEvent {
  final int productId;

  const ToggleFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductBuscarPorNombre extends ProductEvent {
  final String query;

  const ProductBuscarPorNombre(this.query);

  @override
  List<Object?> get props => [query];
}
