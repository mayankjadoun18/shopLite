import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import 'cart_screen_wrapper.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import '../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/cache/my_cache_manager.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final repo = ProductRepository();
  final ScrollController _scrollController = ScrollController();

  List<Product> _allProducts = [];
  List<Product> _visibleProducts = [];
  int _page = 0;
  final int _pageSize = 5;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool _isLoading = false;
  bool _hasError = false;
  bool _isOffline = false; // offline banner

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    // _scrollController.addListener(_onScroll);
  }
  // void _loadNextPage() {
  //   _applyFilters();
  // }

  Future<void> _fetchInitialProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isOffline = false;
    });

    try {
      final products = await repo.fetchProducts();
      setState(() {
        _allProducts = products;
        _applyFilters(reset: true);
      });
    } catch (e) {
      debugPrint("Error loading products: $e");
      // Show offline banner if cache exists
      final cachedProducts = await repo.fetchProducts(forceRefresh: false);
      if (cachedProducts.isNotEmpty) {
        setState(() {
          _allProducts = cachedProducts;
          _applyFilters(reset: true);
          _isOffline = true;
        });
      } else {
        setState(() => _hasError = true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  void _applyFilters({bool reset = false}) {
    final filtered = _allProducts.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (reset) {
      _page = 0;
      _visibleProducts = [];
    }

    final start = _page * _pageSize;
    if (start >= filtered.length) return;
    final end = (start + _pageSize).clamp(0, filtered.length);
    setState(() {
      _visibleProducts.addAll(filtered.sublist(start, end));
      _page++;
    });
  }

  void _loadNextPage() {
    if (!_isLoading) {
      _applyFilters();
    }
  }

  void _toggleCart(Product product, bool isInCart) {
    final cartNotifier = ref.read(cartProvider.notifier);

    if (isInCart) {
      cartNotifier.removeFromCart(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.title} removed from cart')),
      );
    } else {
      cartNotifier.addToCart(product);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.title} added to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final favorites = ref.watch(favoritesProvider);
    final themeMode = ref.watch(themeProvider);
    final loggedIn = ref.watch(authProvider);

    final categories = [
      'All',
      ...{for (var p in _allProducts) p.category ?? 'Uncategorized'},
    ];

    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final iconColor = Theme.of(context).iconTheme.color;
    final cardColor = Theme.of(context).cardColor;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("ShopLite"),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              color: iconColor,
            ),
            onPressed: () {
              ref
                  .read(themeProvider.notifier)
                  .update(
                    (mode) => mode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          // Cart button with auth check
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
            onPressed: () {
              if (!loggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreenWrapper()),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              if (_isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange,
                  padding: const EdgeInsets.all(4),
                  child: const Text(
                    "You are offline - showing cached data",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        hintStyle: TextStyle(
                          color: textColor?.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.search, color: iconColor),
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFilters(reset: true);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      dropdownColor: scaffoldBg,
                      value: _selectedCategory,
                      isExpanded: true,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedCategory = val;
                          _applyFilters(reset: true);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInitialProducts,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      "Loading products...",
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              )
            : _hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: errorColor),
                    const SizedBox(height: 16),
                    Text(
                      "Oops! Something went wrong.",
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchInitialProducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
            : _visibleProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: iconColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No products found.",
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Grid of products
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _visibleProducts.length,
                      itemBuilder: (context, index) {
                        final product = _visibleProducts[index];
                        final isInCart = ref
                            .read(cartProvider.notifier)
                            .isInCart(product.id);
                        final isFavorite = favorites.contains(
                          product.id.toString(),
                        );

                        return Card(
                          color: cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/product_detail',
                                        arguments: product,
                                      );
                                    },
                                    child: Hero(
                                      tag: "product-${product.id}",
                                      child: CachedNetworkImage(
                                        imageUrl: product.image,
                                        cacheManager: MyCacheManager.instance,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: errorColor,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(favoritesProvider.notifier)
                                            .toggleFavorite(
                                              product.id.toString(),
                                            );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isFavorite
                                                  ? 'Removed from favorites'
                                                  : 'Added to favorites',
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                            duration: const Duration(
                                              milliseconds: 800,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  "\$${product.price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  product.category ?? "",
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _toggleCart(product, isInCart),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInCart
                                        ? errorColor
                                        : primaryColor,
                                  ),
                                  child: Text(
                                    isInCart ? "Remove" : "Add to Cart",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Load More button (outside the GridView)
                  if (_visibleProducts.length <
                      _allProducts.where((p) {
                        final matchesSearch = p.title.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                        final matchesCategory =
                            _selectedCategory == 'All' ||
                            p.category == _selectedCategory;
                        return matchesSearch && matchesCategory;
                      }).length)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        onPressed: _loadNextPage,
                        child: const Text("Load More"),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
