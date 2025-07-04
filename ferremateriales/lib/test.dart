import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferremateriales',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const ProductosPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List productos = [];
  bool cargando = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchProductos();
  }

  Future<void> fetchProductos() async {
    final url = Uri.parse('http://192.168.1.16:3000/api/v1/productos'); // Usa tu IP si estás en dispositivo real
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          productos = jsonDecode(response.body);
          cargando = false;
        });
      } else {
        setState(() {
          error = 'Error del servidor: ${response.statusCode}';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.construction),
                        title: Text(producto['nombre'] ?? 'Sin nombre'),
                        subtitle: Text('Precio: \$${producto['precio'] ?? 0}'),
                      ),
                    );
                  },
                ),
    );
  }
}
