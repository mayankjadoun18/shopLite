// lib/data/repositories/product_repository.dart
import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio dio = Dio();

  Future<List<Product>> fetchProducts() async {
    final response = await dio.get('https://fakestoreapi.com/products');
    final data = response.data as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }
}
