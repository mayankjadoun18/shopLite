import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider); // ✅ rebuilds when cart changes
    final favorites = ref.watch(favoritesProvider);

    // ✅ Always derived from provider (auto-refreshes)
    // final isInCart = cart.containsKey(product.id);
    final isInCart = ref.read(cartProvider.notifier).isInCart(product.id);

    final isFavorite = favorites.contains(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(product.id.toString());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? "Removed from favorites"
                        : "Added to favorites",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "product-${product.id}",
              child: Image.network(
                product.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text(product.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            // ✅ Add / Remove toggle button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final cartNotifier = ref.read(cartProvider.notifier);

                  if (isInCart) {
                    cartNotifier.removeFromCart(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${product.title} removed from cart"),
                      ),
                    );
                  } else {
                    cartNotifier.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.title} added to cart")),
                    );
                  }
                },
                icon: Icon(
                  isInCart
                      ? Icons.remove_shopping_cart
                      : Icons.add_shopping_cart,
                ),
                label: Text(isInCart ? "Remove from Cart" : "Add to Cart"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.red : Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
