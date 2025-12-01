import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../productos/bloc/product_bloc.dart';
import '../../productos/bloc/category_bloc.dart';
import '../../productos/services/favorites_service.dart';
import '../../productos/services/cart_service.dart';
import '../../productos/views/main_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Iniciar animación
    _animationController.forward();

    // Cargar datos mientras se muestra el splash
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Cargar cachés de favoritos y carrito primero
      await Future.wait([
        FavoritesService().loadFavoritesCache(),
        CartService().loadCartCache(),
      ]);

      if (!mounted) return;

      final productBloc = context.read<ProductBloc>();
      final categoryBloc = context.read<CategoryBloc>();

      // 2. PRIMERO: Cargar destacados (más vendidos)
      print("🔥 Cargando destacados...");
      productBloc.add(const CargarDestacados(forceRefresh: true));
      
      // Esperar a que los destacados se carguen
      int attempts = 0;
      bool featuredLoaded = false;
      
      while (attempts < 25 && !featuredLoaded) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;

        final currentState = productBloc.state;
        if (currentState is ProductDestacadosSuccess) {
          featuredLoaded = true;
          print("✅ Destacados cargados (${currentState.destacados.length} productos)");
        } else if (currentState is ProductLoadFailure) {
          print("⚠️ Error cargando destacados");
          break;
        }
        attempts++;
      }

      // 3. SEGUNDO: Cargar todos los productos y categorías
      print("📦 Cargando todos los productos...");
      productBloc.add(CargarTodosLosProductos());
      categoryBloc.add(LoadCategories());

      // Esperar a que todos los productos se carguen
      attempts = 0;
      bool allProductsLoaded = false;
      
      while (attempts < 30 && !allProductsLoaded) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;

        final currentState = productBloc.state;
        if (currentState is ProductLoadSuccess) {
          allProductsLoaded = true;
          print("✅ Todos los productos cargados (${currentState.productos.length} productos)");
        } else if (currentState is ProductLoadFailure) {
          print("⚠️ Error cargando todos los productos");
          break;
        }
        attempts++;
      }

      // 4. Esperar un poco para la animación
      await Future.delayed(const Duration(milliseconds: 800));

      // 5. Asegurar que el estado final sea ProductDestacadosSuccess antes de navegar
      // Esto evita que home_view recargue los destacados
      if (mounted) {
        print("🔄 Re-emitiendo destacados para home_view...");
        productBloc.add(const CargarDestacados(forceRefresh: false));
        
        // Esperar a que se emita el estado
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // 6. Navegar a la pantalla principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainView(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      print('Error cargando datos en splash: $e');
      // Navegar de todas formas después de un delay
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainView()));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // Logo con animación de escala
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/images/favicon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.store,
                                size: 150,
                                color: Colors.orange.shade700,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Indicador de carga con animación
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange.shade600,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
