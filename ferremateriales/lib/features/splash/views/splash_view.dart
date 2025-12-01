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

      // 2. Cargar TODOS los productos, destacados (más vendidos) y categorías en paralelo
      final productBloc = context.read<ProductBloc>();
      final categoryBloc = context.read<CategoryBloc>();

      // Cargar productos completos, destacados (más vendidos) y categorías simultáneamente
      productBloc.add(CargarTodosLosProductos());
      productBloc.add(
        CargarDestacados(),
      ); // Obtiene los más vendidos del backend
      categoryBloc.add(LoadCategories());

      // 3. Esperar a que los productos terminen de cargar (máximo 8 segundos)
      print("Esperando a que los productos y destacados se carguen...");
      int attempts = 0;
      bool productsLoaded = false;
      bool featuredLoaded = false;

      while (attempts < 40 && (!productsLoaded || !featuredLoaded)) {
        // 40 intentos * 200ms = 8 segundos máximo
        await Future.delayed(const Duration(milliseconds: 200));

        if (!mounted) return;

        final currentState = productBloc.state;

        if (currentState is ProductLoadSuccess) {
          productsLoaded = true;
          print("✅ Todos los productos cargados");
        } else if (currentState is ProductDestacadosSuccess) {
          featuredLoaded = true;
          print("✅ Productos destacados (más vendidos) cargados");
        } else if (currentState is ProductLoadFailure) {
          print("⚠️ Error cargando productos en el splash");
          break;
        }

        // Si ambos están cargados, salir del loop
        if (productsLoaded && featuredLoaded) {
          print("✅ Todos los datos cargados exitosamente");
          break;
        }

        attempts++;
      }

      // 4. Esperar solo 1 segundo adicional para la animación
      await Future.delayed(const Duration(milliseconds: 1000));

      // 5. Esperar a que la animación termine
      await _animationController.forward();

      // Navegar a la pantalla principal
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
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/favicon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.store,
                                size: 80,
                                color: Colors.orange.shade700,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Indicador de carga con animación
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Texto de carga
                    Text(
                      'Cargando productos...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
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
    );
  }
}
