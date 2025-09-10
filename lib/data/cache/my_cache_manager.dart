import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager {
  static final BaseCacheManager instance = CacheManager(
    Config(
      'ShopLiteImageCache', // Unique key
      stalePeriod: const Duration(days: 7), // Cache valid for 7 days
      maxNrOfCacheObjects: 200, // Max images to store
    ),
  );
}
