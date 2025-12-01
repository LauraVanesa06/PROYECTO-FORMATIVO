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

      // 2. Cargar TODOS los productos, productos destacados y categorías
      final productBloc = context.read<ProductBloc>();
      final categoryBloc = context.read<CategoryBloc>();

      // Iniciar la carga de productos, destacados y categorías
      productBloc.add(CargarDestacados());
      productBloc.add(CargarTodosLosProductos());
      categoryBloc.add(LoadCategories());

      // 3. Esperar a que los productos terminen de cargar (máximo 10 segundos)
      print("Esperando a que los productos se carguen...");
      int attempts = 0;
      while (attempts < 50) {
        // 50 intentos * 200ms = 10 segundos máximo
        await Future.delayed(const Duration(milliseconds: 200));

        if (!mounted) return;

        final currentState = productBloc.state;
        if (currentState is ProductLoadSuccess) {
          print("✅ Productos cargados exitosamente en el splash");
          break;
        } else if (currentState is ProductLoadFailure) {
          print("⚠️ Error cargando productos en el splash");
          break;
        }
        attempts++;
      }

      // 4. Esperar mínimo 2 segundos para mostrar el splash
      await Future.delayed(const Duration(milliseconds: 4000));

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
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo (icono de la app)
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/favicon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Indicador de carga
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange.shade700,
                        ),
                      ),
                    ),
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
