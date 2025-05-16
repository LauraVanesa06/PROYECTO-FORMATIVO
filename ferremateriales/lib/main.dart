 /*import 'package:flutter/material.dart';

void main() {
  runApp(FerreteriaApp());
}

class FerreteriaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferremateriales',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        primaryColor: Colors.red[800],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/header-icon.png', width: 40), // ícono izquierda
                SizedBox(width: 10),
                Column(
                  children: [
                    Text('ERREMATERIALES',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text('EL MAESTRO',
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54)),
                  ],
                ),
                SizedBox(width: 10),
                Image.asset('assets/header-icon2.png', width: 40), // ícono derecha
              ],
            ),
          ),

          // NAVBAR
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _navLink('Inicio'),
                    _navLink('Productos'),
                    _navLink('Contactos'),
                  ],
                ),
                Icon(Icons.login, color: Colors.red[800]),
              ],
            ),
          ),

          // CONTENIDO CENTRAL
          Expanded(
            child: Center(
              child: Text(
                'Contenido de la página',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          // FOOTER
          Container(
            color: Colors.black,
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                '©️ 2025 Ferremateriales. 3456674556y.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.red[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  // Importar flutter_bloc
import 'counter_cubit.dart';  // Importar el archivo donde definimos el Cubit

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => CounterCubit(),  // Crear y proveer el Cubit
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cubit Counter Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el estado actual del contador
            BlocBuilder<CounterCubit, int>(
              builder: (context, state) {
                return Text(
                  'Contador: $state',  // Mostrar el valor del contador
                  style: TextStyle(fontSize: 40),
                );
              },
            ),
            SizedBox(height: 20),
            // Botón para incrementar el contador
            ElevatedButton(
              onPressed: () => context.read<CounterCubit>().increment(), // Incrementar contador
              child: Text('Incrementar'),
            ),
            SizedBox(height: 20),
            // Botón para incrementar el contador
            ElevatedButton(
              onPressed: () => context.read<CounterCubit>().descrementar(), // Incrementar contador
              child: Text('descrementar'),
            ),
            SizedBox(height: 20),
            // Botón para resetear el contador
            ElevatedButton(
              onPressed: () => context.read<CounterCubit>().reset(), // Resetear contador
              child: Text('Resetear'),
            ),
          ],
        ),
      ),
    );
  }
} 
