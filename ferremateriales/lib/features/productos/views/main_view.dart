import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/views/login_view.dart';
import '../services/favorites_service.dart';
import '../services/cart_service.dart';
import 'home_view.dart';
import 'favorites_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';

// GlobalKey para acceder al estado de MainView desde otros widgets
final GlobalKey<_MainViewState> mainViewKey = GlobalKey<_MainViewState>();

class MainView extends StatefulWidget {
  final int initialIndex;
  
  MainView({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}



class _MainViewState extends State<MainView> {
  late int _selectedIndex;

  // Método público para cambiar de tab desde otros widgets
  void changeTab(int index) {
    if (mounted && index >= 0 && index < 4) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Cargar cachés al iniciar (una sola petición HTTP para cada uno)
    _loadCaches();
  }

  Future<void> _loadCaches() async {
    await FavoritesService().loadFavoritesCache();
    await CartService().loadCartCache();
    
    // Forzar actualización de la UI después de cargar cachés
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final nombre = authState.nombre ?? "";

    final List<Widget> _screens = [
      const HomeView(),
      const FavoritesView(),
      const CartView(),
      ProfileView(userName: nombre),
    ];

return Scaffold(
  extendBody: true,
  body: _screens[_selectedIndex],

  // 🎨 Barra inferior moderna y limpia
  bottomNavigationBar: Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
    ),
    child: SafeArea(
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0, authState),
            _buildNavItem(Icons.favorite, 1, authState),
            _buildCartFAB(authState),
            _buildNavItem(Icons.person, 3, authState),
          ],
        ),
      ),
    ),
  ),
);




  }

  // Widget para cada item del navigation bar
  Widget _buildNavItem(IconData icon, int index, AuthState authState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (authState.status == AuthStatus.guest && (index == 1 || index == 2)) {
          _showAuthDialogForSection(index);
          return;
        }
        setState(() => _selectedIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2e67a3).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? const Color(0xFF2e67a3) 
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          size: 28,
        ),
      ),
    );
  }

  // Widget para el botón del carrito (FAB integrado)
  Widget _buildCartFAB(AuthState authState) {
    return GestureDetector(
      onTap: () {
        if (authState.status == AuthStatus.guest) {
          _showAuthDialogForCart();
          return;
        }
        setState(() => _selectedIndex = 2);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF2e67a3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2e67a3).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // Diálogo de autenticación para el carrito
  void _showAuthDialogForCart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2e67a3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Color(0xFF2e67a3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Acceso al carrito',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Para acceder a tu carrito de compras necesitas iniciar sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF2e67a3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continuar como invitado',
                          style: TextStyle(
                            color: Color(0xFF2e67a3),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2e67a3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Diálogo de autenticación para secciones protegidas
  void _showAuthDialogForSection(int sectionIndex) {
    final sectionName = sectionIndex == 1 ? 'favoritos' : 'el carrito';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2e67a3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sectionIndex == 1 ? Icons.favorite_outline : Icons.shopping_cart_outlined,
                    size: 48,
                    color: const Color(0xFF2e67a3),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  sectionIndex == 1 ? 'Acceso a favoritos' : 'Acceso al carrito',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Para acceder a $sectionName necesitas iniciar sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF2e67a3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continuar como invitado',
                          style: TextStyle(
                            color: Color(0xFF2e67a3),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2e67a3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
