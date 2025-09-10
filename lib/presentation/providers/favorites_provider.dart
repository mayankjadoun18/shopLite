// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
//   (ref) {
//     return FavoritesNotifier();
//   },
// );
//
// class FavoritesNotifier extends StateNotifier<Set<String>> {
//   static const _boxName = 'favorites';
//   late final Box<String> _box;
//
//   FavoritesNotifier() : super({}) {
//     _box = Hive.box<String>(_boxName); // Opens the Hive box
//     state = _box.values.toSet(); // Load existing favorites
//   }
//
//   void toggleFavorite(String productId) {
//     if (state.contains(productId)) {
//       _box.delete(productId);
//       state = {...state}..remove(productId);
//     } else {
//       _box.put(productId, productId);
//       state = {...state}..add(productId);
//     }
//   }
//
//   bool isFavorite(String productId) => state.contains(productId);
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const _boxName = 'favorites';
  Box<String>? _box;

  FavoritesNotifier() : super(<String>{}) {
    _init();
  }

  Future<void> _init() async {
    // Ensure the box is opened (avoid error if not opened in main.dart)
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<String>(_boxName);
    } else {
      _box = Hive.box<String>(_boxName);
    }

    // Load stored favorites
    state = _box!.keys.cast<String>().toSet();
  }

  Future<void> toggleFavorite(String productId) async {
    if (state.contains(productId)) {
      await _box?.delete(productId);
      state = {...state}..remove(productId);
    } else {
      await _box?.put(productId, productId);
      state = {...state}..add(productId);
    }
  }

  bool isFavorite(String productId) => state.contains(productId);
}
