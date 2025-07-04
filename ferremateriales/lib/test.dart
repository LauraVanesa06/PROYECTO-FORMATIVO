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
  bool cargando = false;
  String error = '';

  Future<void> fetchProductos() async {
    setState(() {
      cargando = true;
      error = '';
    });

    final url = Uri.parse('http://192.168.1.16:3000/api/v1/productos');

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
      body: Column(
        children: [
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchProductos,
            icon: const Icon(Icons.search),
            label: const Text('Consultar Productos'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
                    : productos.isEmpty
                        ? const Center(child: Text('No hay productos cargados.'))
                        : ListView.builder(
                            itemCount: productos.length,
                            itemBuilder: (context, index) {
                              final producto = productos[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(producto['nombre'] ?? 'Sin nombre',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(producto['descripcion'] ?? 'Sin descripción'),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('💰 \$${producto['precio']}'),
                                          Text('📦 Stock: ${producto['stock']}'),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Categoría ID: ${producto['category_id']} - Proveedor ID: ${producto['supplier_id']}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
