import 'package:equatable/equatable.dart';


class ProductModel extends Equatable {
  final int? id;
  final String? nombre;
  final String? descripcion;
  final double? precio;
  final int? stock;
  final String? imagenUrl;

  const ProductModel({
    this.id,
    this.nombre,
    this.descripcion,
    this.precio, 
    this.stock,
    this.imagenUrl,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      imagenUrl: json['imagen_url'] ?? '',
    );

  @override
  List<Object?> get props => [id, nombre, descripcion, precio, stock, imagenUrl];
}
