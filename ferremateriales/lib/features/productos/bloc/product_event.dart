part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

// 🚀 Cargar productos iniciales (los más vendidos o por categoría)
class ProductEntrarPressed extends ProductEvent {}

// 🏷️ Filtrar productos por categoría (usa category_id)
class ProductFilterByCategory extends ProductEvent {
  final int categoryId;

  const ProductFilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

// ❤️ Marcar o desmarcar producto como favorito
class ToggleFavorite extends ProductEvent {
  final int productId;

  const ToggleFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}

// 🔍 Buscar productos por nombre o descripción
class ProductBuscarPorNombre extends ProductEvent {
  final String query;

  const ProductBuscarPorNombre(this.query);

  @override
  List<Object?> get props => [query];
}
