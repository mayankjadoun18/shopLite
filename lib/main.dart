import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/catalog_screen.dart';
import 'presentation/screens/cart_screen_wrapper.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/product_detail_screen.dart';
import 'data/models/product_model.dart';
import 'presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('favorites');

  runApp(const ProviderScope(child: ShopLiteApp()));
}

class ShopLiteApp extends ConsumerWidget {
  const ShopLiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'ShopLite',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      // Start with splash
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/catalog': (_) => const CatalogScreen(),
        '/login': (_) => const LoginScreen(),
        '/cart': (_) => const CartScreenWrapper(), // guarded
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
