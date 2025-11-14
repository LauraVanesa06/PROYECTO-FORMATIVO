part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

// SOLO HOME
final class CargarDestacados extends ProductEvent {}

// SOLO BÚSQUEDA
final class CargarTodosLosProductos extends ProductEvent {}

// BUSCAR
final class ProductBuscarPorNombre extends ProductEvent {
  final String nombre;
  const ProductBuscarPorNombre(this.nombre);
}

// FILTRAR
final class ProductFilterByCategory extends ProductEvent {
  final int categoryId;
  const ProductFilterByCategory(this.categoryId);
}

// FAVORITO
final class ToggleFavorite extends ProductEvent {
  final int productId;
  const ToggleFavorite(this.productId);
}
