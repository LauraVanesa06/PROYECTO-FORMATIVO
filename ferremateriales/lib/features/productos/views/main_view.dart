import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'home_view.dart';
import 'favorites_view.dart';
import 'cart_view.dart';
import 'notifications_view.dart';
import 'profile_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}



class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final nombre = authState.nombre ?? "";

    final List<Widget> _screens = [
      const HomeView(),
      const FavoritesView(),
      const CartView(),
      const NotificationsView(),
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
            _buildNavItem(Icons.star, 1, authState),
            _buildCartFAB(authState),
            _buildNavItem(Icons.notifications, 3, authState),
            _buildNavItem(Icons.person, 4, authState),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Inicia sesión para acceder a esta sección 🔒'),
            backgroundColor: Colors.orange,
          ));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Inicia sesión para acceder al carrito 🔒'),
            backgroundColor: Colors.orange,
          ));
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
}
