// lib/presentation/providers/cart_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/models/product_model.dart';
//
// class CartNotifier extends StateNotifier<List<Product>> {
//   CartNotifier() : super([]);
//
//   void addToCart(Product product) {
//     state = [...state, product];
//   }
//
//   void removeFromCart(Product product) {
//     state = state.where((p) => p.id != product.id).toList();
//   }
//
//   double get total => state.fold(0, (sum, item) => sum + item.price);
// }
//
// final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>(
//   (ref) => CartNotifier(),
// );
// lib/presentation/providers/cart_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/models/product_model.dart';
//
// /// Represents one line item in the cart
// class CartItem {
//   final Product product;
//   final int quantity;
//
//   const CartItem({required this.product, required this.quantity});
//
//   CartItem copyWith({Product? product, int? quantity}) {
//     return CartItem(
//       product: product ?? this.product,
//       quantity: quantity ?? this.quantity,
//     );
//   }
//
//   double get total => product.price * quantity;
// }
//
// class CartNotifier extends StateNotifier<Map<int, CartItem>> {
//   CartNotifier() : super({});
//
//   /// Add a product to the cart (or increase quantity if it exists)
//   void addToCart(Product product, {int qty = 1}) {
//     final current = state[product.id];
//     if (current != null) {
//       state = {
//         ...state,
//         product.id: current.copyWith(quantity: current.quantity + qty),
//       };
//     } else {
//       state = {...state, product.id: CartItem(product: product, quantity: qty)};
//     }
//   }
//
//   /// Remove a product entirely from the cart
//   void removeFromCart(int productId) {
//     final updated = {...state}..remove(productId);
//     state = updated;
//   }
//
//   /// Update the quantity of a product
//   void updateQuantity(int productId, int qty) {
//     if (!state.containsKey(productId)) return;
//
//     if (qty <= 0) {
//       removeFromCart(productId);
//     } else {
//       state = {...state, productId: state[productId]!.copyWith(quantity: qty)};
//     }
//   }
//
//   /// Clear all items
//   void clearCart() => state = {};
//
//   /// Totals
//   double get subtotal => state.values.fold(0, (sum, item) => sum + item.total);
//
//   double get tax => subtotal * 0.12; // Example 12% tax
//   double get shipping => state.isEmpty ? 0.0 : 49.0; // Flat shipping
//   double get total => subtotal + tax + shipping;
//
//   /// Mock place order
//   Future<void> placeOrder() async {
//     await Future.delayed(const Duration(seconds: 1));
//     clearCart();
//   }
// }
//
// final cartProvider = StateNotifierProvider<CartNotifier, Map<int, CartItem>>(
//   (ref) => CartNotifier(),
// );
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

/// Represents one line item in the cart
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => product.price * quantity;
}

class CartNotifier extends StateNotifier<Map<int, CartItem>> {
  CartNotifier() : super({});

  /// Add a product to the cart (or increase quantity if it exists)
  void addToCart(Product product, {int qty = 1}) {
    final current = state[product.id];
    if (current != null) {
      state = {
        ...state,
        product.id: current.copyWith(quantity: current.quantity + qty),
      };
    } else {
      state = {...state, product.id: CartItem(product: product, quantity: qty)};
    }
  }

  /// Remove a product entirely from the cart
  void removeFromCart(int productId) {
    if (!state.containsKey(productId)) return;
    final updated = {...state}..remove(productId);
    state = updated;
  }

  /// Update the quantity of a product
  void updateQuantity(int productId, int qty) {
    if (!state.containsKey(productId)) return;

    if (qty <= 0) {
      removeFromCart(productId);
    } else {
      state = {...state, productId: state[productId]!.copyWith(quantity: qty)};
    }
  }

  /// Check if a product is in cart
  bool isInCart(int productId) => state.containsKey(productId);

  /// Clear all items
  void clearCart() => state = {};

  /// Totals
  double get subtotal => state.values.fold(0, (sum, item) => sum + item.total);

  double get tax => subtotal * 0.12; // Example 12% tax
  double get shipping => state.isEmpty ? 0.0 : 49.0; // Flat shipping
  double get total => subtotal + tax + shipping;

  /// Mock place order
  Future<void> placeOrder() async {
    await Future.delayed(const Duration(seconds: 1));
    clearCart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<int, CartItem>>(
  (ref) => CartNotifier(),
);
