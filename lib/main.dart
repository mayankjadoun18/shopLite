import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/catalog_screen.dart';
import 'presentation/screens/cart_screen.dart';
import 'presentation/screens/product_detail_screen.dart';
import 'data/models/product_model.dart';

void main() {
  runApp(const ProviderScope(child: ShopLiteApp()));
}

class ShopLiteApp extends StatelessWidget {
  const ShopLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopLite',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const CatalogScreen(),
        '/cart': (_) => const CartScreen(),
        // ProductDetailScreen will use onGenerateRoute to pass arguments
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
