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
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        precio: (json['precio'] as num).toDouble(),
        stock: json['stock'],
        imagenUrl: json['imagenUrl'],
      );

  @override
  List<Object?> get props => [id, nombre, descripcion, precio, stock, imagenUrl];
}
