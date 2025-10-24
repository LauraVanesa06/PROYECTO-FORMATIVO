import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'home_view.dart';
import 'favorites_view.dart';
import 'cart_view.dart';
import 'notifications_view.dart';
import '../../auth/bloc/auth_state.dart';
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
  extendBody: true, // Permite que el fondo se extienda detrás del BottomAppBar
  body: _screens[_selectedIndex],

  // 🪵 Barra inferior personalizada
  bottomNavigationBar: ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    child: BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      height: 65, // altura controlada
      padding: EdgeInsets.zero,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/madera2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (authState.status == AuthStatus.guest &&
                (index == 1 || index == 2)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Inicia sesión para acceder a esta sección 🔒'),
                backgroundColor: Colors.orange,
              ));
              return;
            }
            setState(() => _selectedIndex = index);
          },
          selectedItemColor: const Color.fromARGB(255, 130, 204, 238),
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''), // espacio FAB
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    ),
  ),

  // 🛒 FAB centrado perfectamente
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  floatingActionButton: Transform.translate(
    offset: const Offset(0, 5), // 🔧 bajamos el FAB 5px
    child: FloatingActionButton(
      onPressed: () {
        if (authState.status == AuthStatus.guest) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Inicia sesión para acceder al carrito 🔒'),
            backgroundColor: Colors.orange,
          ));
          return;
        }
        setState(() => _selectedIndex = 2);
      },
      backgroundColor: const Color.fromARGB(255, 91, 165, 207),
      child: const Icon(Icons.shopping_cart, color: Colors.white),
    ),
  ),
);




  }
}
