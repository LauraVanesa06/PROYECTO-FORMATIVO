import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int? id;
  final String? nombre;
  final String? descripcion;
  final double? precio;
  final int? stock;
  final String? imagenUrl;
  final bool isFavorite; // ✅ Nuevo campo

  const ProductModel({
    this.id,
    this.nombre,
    this.descripcion,
    this.precio,
    this.stock,
    this.imagenUrl,
    this.isFavorite = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',
        descripcion: json['descripcion'] ?? '',
        precio: double.tryParse(json['precio'].toString()) ?? 0.0,
        stock: int.tryParse(json['stock'].toString()) ?? 0,
        imagenUrl: json['imagen_url'] ?? "",
        isFavorite: json['favorito'] ?? false,
      );

  ProductModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? imagenUrl,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        precio,
        stock,
        imagenUrl,
        isFavorite,
      ];

      Map<String, dynamic> toJson() {
        return {
          'id': id,
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'stock': stock,
          'imagen_url': imagenUrl,
          'favorito': isFavorite,
        };
      }

}