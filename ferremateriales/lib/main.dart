
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'features/productos/bloc/product_bloc.dart';
  import 'features/productos/views/initial_view.dart';
  import 'features/productos/views/products_view.dart';
  import 'views/failure_view.dart';
  import 'views/loading_view.dart';


  void main() {
    runApp(Ferreteria());
  }

  class Ferreteria extends StatelessWidget {
    const Ferreteria({super.key});

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => ProductBloc(),
        child: MaterialApp(
          
          home: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoadInProgress) {
                return LoadingView();
              } else if (state is ProductLoadFailure) {
                return FailureView();
              } else if (state is ProductLoadSuccess) {
                return ProductsPageView();
              } else if (state is ProductInitial) {
                return InitialView();
              }
              return InitialView();
            },
          ),
        ),
      );
    }
  }

































/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/productos/views/products_view.dart';
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
                Image.asset('assets/header-icon.png', width: 40),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text('FERREMATERIALES',
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
                Image.asset('assets/header-icon2.png', width: 40),
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
                    _navLink(context, 'Inicio'),
                    _navLink(context, 'Productos'),
                    _navLink(context, 'Contactos'),
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

  Widget _navLink(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        if (text == 'Productos') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductsView()),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(right: 16),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.red[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

} */

/* BOTON INCREMENTAR 

 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  // Importar flutter_bloc
import 'counter_cubit.dart';  // Importar el archivo donde definimos el Cubit

void main() {
  runApp(MyApp());

}
 */



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
*/

/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'valor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: BlocProvider(
        create: (_) => Valor(),
        child: PrecioPage(),
    ),
    );
  }
}

class PrecioPage extends StatefulWidget {
  const PrecioPage({Key? key}) : super(key: key); 
  @override
  _PrecioPageState createState() => _PrecioPageState();
}
  

class _PrecioPageState extends State<PrecioPage> {
  final TextEditingController _controller = TextEditingController();

  void _guardarPrecio() {
    final texto = _controller.text;
    final precio = double.tryParse(texto);  
    if (precio != null) {
      context.read<Valor>().establecerValor(precio);
    }
  }    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Precio del producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Ingrese el precio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarPrecio,
              child: Text('Guardar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<Valor>().descuento1(),
              child: Text('Aplicar descuento 50%'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              
              onPressed: () => context.read<Valor>().descuento2(),
              child: Text('Aplicar descuento 75%'),
            ),
            SizedBox(height: 20),
            BlocBuilder<Valor, double?>(
              builder: (context, precio) {
                if (precio == null) {
                  return Text('Aún no hay precio ingresado');
                }
                return Text('Precio guardado: \$${precio.toStringAsFixed(2)}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/

