import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ferremateriales/features/productos/services/cart_service.dart';
import 'package:ferremateriales/features/productos/models/cart_item_model.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc({CartService? cartService})
      : _cartService = cartService ?? CartService(),
        super(const CartState()) {
    
    // 📋 Cargar carrito desde el backend
    on<LoadCart>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final items = await _cartService.getCartItems();
        emit(state.copyWith(items: items, isLoading: false));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    });

    // ➕ Agregar al carrito
    on<AddToCart>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await _cartService.addToCart(event.productId);
        final items = await _cartService.getCartItems();
        emit(state.copyWith(items: items, isLoading: false));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    });

    // ❌ Eliminar del carrito
    on<RemoveFromCart>((event, emit) async {
      // Actualización optimista: eliminar del carrito localmente
      final updatedItems = state.items.where((item) => item.id != event.id).toList();
      
      emit(state.copyWith(items: updatedItems));
      
      // Eliminar en el backend en segundo plano
      try {
        await _cartService.removeItem(event.id);
      } catch (e) {
        // Si falla, recargar desde el servidor
        try {
          final items = await _cartService.getCartItems();
          emit(state.copyWith(items: items, error: e.toString()));
        } catch (_) {
          emit(state.copyWith(error: e.toString()));
        }
      }
    });

    // 🔼 Incrementar cantidad
    on<IncreaseQuantity>((event, emit) async {
      // Actualización optimista: incrementar cantidad localmente
      final updatedItems = state.items.map((item) {
        if (item.id == event.id) {
          return CartItemModel(
            id: item.id,
            quantity: item.quantity + 1,
            product: item.product,
          );
        }
        return item;
      }).toList();
      
      emit(state.copyWith(items: updatedItems));
      
      // Actualizar en el backend en segundo plano
      try {
        await _cartService.increaseQuantity(event.id);
      } catch (e) {
        // Si falla, recargar desde el servidor
        try {
          final items = await _cartService.getCartItems();
          emit(state.copyWith(items: items, error: e.toString()));
        } catch (_) {
          emit(state.copyWith(error: e.toString()));
        }
      }
    });

    // 🔽 Disminuir cantidad
    on<DecreaseQuantity>((event, emit) async {
      // Actualización optimista: decrementar cantidad localmente
      final updatedItems = state.items.map((item) {
        if (item.id == event.id) {
          final newQuantity = item.quantity - 1;
          if (newQuantity > 0) {
            return CartItemModel(
              id: item.id,
              quantity: newQuantity,
              product: item.product,
            );
          }
          return null; // Será filtrado
        }
        return item;
      }).whereType<CartItemModel>().toList();
      
      emit(state.copyWith(items: updatedItems));
      
      // Actualizar en el backend en segundo plano
      try {
        await _cartService.decreaseQuantity(event.id);
      } catch (e) {
        // Si falla, recargar desde el servidor
        try {
          final items = await _cartService.getCartItems();
          emit(state.copyWith(items: items, error: e.toString()));
        } catch (_) {
          emit(state.copyWith(error: e.toString()));
        }
      }
    });

    // 🗑 Vaciar carrito
    on<ClearCart>((event, emit) {
      emit(const CartState(items: []));
    });
  }
}
