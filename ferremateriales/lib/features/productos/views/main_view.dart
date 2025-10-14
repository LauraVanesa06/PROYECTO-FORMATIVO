import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
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
    // Obtén el nombre del usuario desde el AuthBloc
    final nombre = context.watch<AuthBloc>().state.nombre ?? "";

    final List<Widget> _screens = [
      const HomeView(),
      const FavoritesView(),
      const CartView(),
      const NotificationsView(),
      ProfileView(userName: nombre),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 55, // Altura controlada de la barra inferior
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Fondo de madera limitado a 65 de alto
            Container(
              height: 55,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/madera2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Barra de navegación sin texto y con ícono sobresaliente
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: const Color.fromARGB(255, 130, 204, 238),
              unselectedItemColor: Colors.white,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: const Offset(0, -35), // Carrito sobresaliente
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 130, 204, 238),
                            Color.fromARGB(255, 91, 165, 207)
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                    ),
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}