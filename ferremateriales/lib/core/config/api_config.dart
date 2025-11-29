/// Configuración central de la API
/// 
/// IMPORTANTE: Cambia esta URL según tu entorno:
/// - Para desarrollo local en Android Emulator: 'http://10.0.2.2:3000'
/// - Para desarrollo local en web: 'http://localhost:3000'
/// - Para desarrollo en dispositivo físico: usa la IP de tu máquina (ejemplo: 'http://192.168.1.10:3000')
/// - Para ngrok: 'https://tu-subdominio.ngrok-free.app'
class ApiConfig {
  // 🔧 CAMBIA ESTA URL SEGÚN TU ENTORNO
  // 10.0.2.2 es la IP especial del emulador de Android que apunta al localhost de tu máquina
  static const String baseUrl = 'http://localhost:3000';
  
  // Headers comunes para todas las peticiones
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
  
  // Endpoints de la API
  static const String productsEndpoint = '/api/v1/products';
  static const String allProductsEndpoint = '/api/v1/products/all_products';
  static const String categoriesEndpoint = '/api/v1/categories';
  static const String favoritesEndpoint = '/api/v1/favorites';
  static const String cartItemsEndpoint = '/api/v1/cart_items';
  static const String paymentsEndpoint = '/api/v1/payments/create_checkout';
  
  // URLs completas (helpers)
  static String get productsUrl => '$baseUrl$productsEndpoint';
  static String get allProductsUrl => '$baseUrl$allProductsEndpoint';
  static String get categoriesUrl => '$baseUrl$categoriesEndpoint';
  static String get favoritesUrl => '$baseUrl$favoritesEndpoint';
  static String get cartItemsUrl => '$baseUrl$cartItemsEndpoint';
  static String get paymentsUrl => '$baseUrl$paymentsEndpoint';
  
  // Helper para construir URLs con query params
  static String productsByCategoryUrl(int categoryId) =>
      '$baseUrl$productsEndpoint?category_id=$categoryId';
}
