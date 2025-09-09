import 'package:flutter/material.dart';
import 'checkout_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> cartItems = [
    {"title": "Product 1", "price": 20.0, "qty": 1},
    {"title": "Product 2", "price": 30.0, "qty": 2},
  ];

  double get total =>
      cartItems.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['title']),
                  subtitle: Text("\$${item['price']} x ${item['qty']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => cartItems.removeAt(index));
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutSuccessScreen(),
                      ),
                    );
                  },
                  child: const Text("Place Order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
