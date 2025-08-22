import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    // ➕ Agregar al carrito
    on<AddToCart>((event, emit) {
      final items = List<Map<String, dynamic>>.from(state.items);
      final index = items.indexWhere((item) => item["name"] == event.product["name"]);

      if (index >= 0) {
        items[index]["quantity"] += 1;
      } else {
        items.add({...event.product, "quantity": 1});
      }

      emit(CartState(items: items));
    });

    // ❌ Eliminar del carrito
    on<RemoveFromCart>((event, emit) {
      final items = state.items.where((item) => item["name"] != event.name).toList();
      emit(CartState(items: items));
    });

    // 🔼 Incrementar
    on<IncreaseQuantity>((event, emit) {
      final items = List<Map<String, dynamic>>.from(state.items);
      final index = items.indexWhere((item) => item["name"] == event.name);

      if (index >= 0) {
        items[index]["quantity"] += 1;
      }

      emit(CartState(items: items));
    });

    // 🔽 Disminuir
    on<DecreaseQuantity>((event, emit) {
      final items = List<Map<String, dynamic>>.from(state.items);
      final index = items.indexWhere((item) => item["name"] == event.name);

      if (index >= 0) {
        if (items[index]["quantity"] > 1) {
          items[index]["quantity"] -= 1;
        } else {
          items.removeAt(index);
        }
      }

      emit(CartState(items: items));
    });

    // 🗑 Vaciar carrito (👉 lo que te faltaba)
    on<ClearCart>((event, emit) {
      emit(const CartState(items: []));
    });
  }
}
