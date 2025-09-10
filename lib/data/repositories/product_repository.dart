// lib/data/repositories/product_repository.dart
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio dio = Dio();
  final String _productsBoxName = 'productsBox';
  final Duration cacheTTL = const Duration(minutes: 30);

  /// Initialize Hive box
  Future<Box> _openBox() async {
    return await Hive.openBox(_productsBoxName);
  }

  /// Fetch products from API or cache
  Future<List<Product>> fetchProducts({bool forceRefresh = false}) async {
    final box = await _openBox();

    // Check cache
    if (!forceRefresh &&
        box.containsKey('products') &&
        box.containsKey('cacheTime')) {
      final cacheTime = box.get('cacheTime') as DateTime;
      final now = DateTime.now();

      if (now.difference(cacheTime) < cacheTTL) {
        final cachedData = box.get('products') as List<dynamic>;
        return cachedData
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    // Fetch from API
    try {
      final response = await dio.get('https://fakestoreapi.com/products');
      final data = response.data as List;

      // Save to cache
      await box.put('products', data);
      await box.put('cacheTime', DateTime.now());

      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      // On error, fallback to cached data if available
      if (box.containsKey('products')) {
        final cachedData = box.get('products') as List<dynamic>;
        return cachedData
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      rethrow; // no cache available
    }
  }

  /// Fetch paginated products
  Future<List<Product>> fetchProductsPage(int page, int pageSize) async {
    final allProducts = await fetchProducts();
    final start = page * pageSize;
    if (start >= allProducts.length) return [];
    final end = (start + pageSize).clamp(0, allProducts.length);
    return allProducts.sublist(start, end);
  }
}
