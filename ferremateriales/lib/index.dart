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
            ElevatedButton(
              onPressed: () => context.read<CounterCubit>().descrementar(), // Resetear contador
              child: Text('Descrementar'),
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
