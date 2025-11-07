import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    // ➕ Agregar al carrito
    on<AddToCart>((event, emit) {
      final existingIndex = state.items.indexWhere(
        (item) => item["name"] == event.product["name"]
      );

      final List<Map<String, dynamic>> items;
      
      if (existingIndex >= 0) {
        items = state.items.map((item) {
          if (item["name"] == event.product["name"]) {
            return {...item, "quantity": (item["quantity"] as int) + 1};
          }
          return {...item};
        }).toList();
      } else {
        items = [...state.items.map((item) => {...item}), {...event.product, "quantity": 1}];
      }

      emit(CartState(items: items));
    });

    // ❌ Eliminar del carrito
    on<RemoveFromCart>((event, emit) {
      final items = state.items
          .where((item) => item["name"] != event.name)
          .map((item) => {...item})
          .toList();
      emit(CartState(items: items));
    });

    // 🔼 Incrementar
    on<IncreaseQuantity>((event, emit) {
      final items = state.items.map((item) {
        if (item["name"] == event.name) {
          return {...item, "quantity": (item["quantity"] as int) + 1};
        }
        return {...item};
      }).toList();

      emit(CartState(items: items));
    });

    // 🔽 Disminuir
    on<DecreaseQuantity>((event, emit) {
      final items = <Map<String, dynamic>>[];
      
      for (var item in state.items) {
        if (item["name"] == event.name) {
          final newQuantity = (item["quantity"] as int) - 1;
          if (newQuantity > 0) {
            items.add({...item, "quantity": newQuantity});
          }
          // Si newQuantity es 0, no agregamos el item (lo eliminamos)
        } else {
          items.add({...item});
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
