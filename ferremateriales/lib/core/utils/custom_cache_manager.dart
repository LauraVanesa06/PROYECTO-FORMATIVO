import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static final instance = CacheManager(
    Config(
      'productImageCache',
      stalePeriod: const Duration(days: 14), // Guarda las imágenes 14 días
      maxNrOfCacheObjects: 200, // Hasta 200 imágenes
      repo: JsonCacheInfoRepository(databaseName: 'productCache'),
      fileService: HttpFileService(),
    ),
  );
}
