import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Ferreteria());
}

class Ferreteria extends StatelessWidget {
  const Ferreteria({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthStarted())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState.status == AuthStatus.initial ||
                authState.status == AuthStatus.failure) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginView()),
                (route) => false,
              );
            }
            if (authState.status == AuthStatus.loggedOut) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScaffold()),
                (route) => false,
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState.status == AuthStatus.success) {
                return const MainScaffold();
              } else {
                return LoginView();
              }
            },
          ),
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeView(),
    const Center(child: Text('Favoritos')),
    const Center(child: Text('Carrito')),
    const Center(child: Text('Notificaciones')),
    const Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerImages = [
      'https://picsum.photos/400/200?random=1',
      'https://picsum.photos/400/200?random=2',
      'https://picsum.photos/400/200?random=3',
    ];

    final categories = [
      {'icon': Icons.construction, 'label': 'Herramientas'},
      {'icon': Icons.plumbing, 'label': 'Plomería'},
      {'icon': Icons.electrical_services, 'label': 'Electricidad'},
      {'icon': Icons.format_paint, 'label': 'Pintura'},
      {'icon': Icons.chair, 'label': 'Muebles'},
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Ferretería', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),

          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: bannerImages.length,
              controller: PageController(viewportFraction: 0.85),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      bannerImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Icon(category['icon'] as IconData, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 6),
                    Text(category['label'] as String),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
