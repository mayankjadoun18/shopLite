// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/models/product_model.dart';
// import '../../data/repositories/product_repository.dart';
// import '../providers/cart_provider.dart';
// import 'cart_screen.dart';
// import 'product_detail_screen.dart';
//
// class CatalogScreen extends ConsumerStatefulWidget {
//   const CatalogScreen({super.key});
//
//   @override
//   ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
// }
//
// class _CatalogScreenState extends ConsumerState<CatalogScreen> {
//   final repo = ProductRepository();
//   late Future<List<Product>> _productsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _productsFuture = repo.fetchProducts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cart = ref.watch(cartProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("ShopLite"),
//         actions: [
//           IconButton(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.shopping_cart),
//                 if (cart.isNotEmpty)
//                   Positioned(
//                     right: 0,
//                     child: CircleAvatar(
//                       radius: 8,
//                       backgroundColor: Colors.red,
//                       child: Text(
//                         '${cart.length}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const CartScreen()),
//             ),
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Product>>(
//         future: _productsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No products found.'));
//           }
//
//           final products = snapshot.data!;
//
//           return GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.7,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//
//               return Card(
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 ProductDetailScreen(product: product),
//                           ),
//                         );
//                       },
//                       child: Hero(
//                         tag: "product-${product.id}",
//                         child: Image.network(
//                           product.image,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 4,
//                       ),
//                       child: Text(
//                         product.title,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Text("\$${product.price}"),
//                     const SizedBox(height: 4),
//                     ElevatedButton(
//                       onPressed: () {
//                         ref.read(cartProvider.notifier).addToCart(product);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Added to cart')),
//                         );
//                       },
//                       child: const Text("Add to Cart"),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final repo = ProductRepository();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = repo.fetchProducts();
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ShopLite"),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cart.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isInCart = cart.any((p) => p.id == product.id);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Hero(
                        tag: "product-${product.id}",
                        child: Image.network(
                          product.image,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        product.category != null ? product.category : " ",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? Colors.grey : Colors.blue,
                        ),
                        child: Text(isInCart ? "In Cart" : "Add to Cart"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
