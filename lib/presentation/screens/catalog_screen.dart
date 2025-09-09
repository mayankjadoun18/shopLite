import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyProducts = List.generate(
      10,
      (i) => {
        "id": i,
        "title": "Product $i",
        "price": 20.0 + i,
        "image": "https://via.placeholder.com/150",
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("ShopLite"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: dummyProducts.length,
        itemBuilder: (context, index) {
          final product = dummyProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
            child: Card(
              child: Column(
                children: [
                  Hero(
                    tag: "product-${product['id']}",
                    child: Image.network(
                      product['image'] as String,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    product['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("\$${product['price']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
