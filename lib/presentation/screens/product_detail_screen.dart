import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['title'])),
      body: Column(
        children: [
          Hero(
            tag: "product-${product['id']}",
            child: Image.network(product['image'], height: 200),
          ),
          const SizedBox(height: 20),
          Text(
            product['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text("\$${product['price']}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Added to Cart")));
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}
