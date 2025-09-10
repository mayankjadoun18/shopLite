import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class CartScreenWrapper extends ConsumerWidget {
  const CartScreenWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(authProvider);

    if (!loggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const CartScreen();
  }
}
