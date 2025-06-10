# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Limpia las tablas en orden inverso para evitar errores por dependencias
PurchaseDetail.delete_all
Buy.delete_all
Product.delete_all
Category.delete_all
Supplier.delete_all
Customer.delete_all
Proveedor.delete_all
User.delete_all

# Crear usuarios
User.create!(
  email: "admin@example.com",
  password: "password",
  role: "admin"
)

# Crear categorías
categories = Category.create!([
  { nombre: "Electrónica" },
  { nombre: "Hogar" },
  { nombre: "Ropa" }
])

# Crear proveedores (en inglés y español, como aparecen ambos en tu schema)
suppliers = Supplier.create!([
  { nombre: "Proveedor Uno", contacto: "Carlos Pérez" },
  { nombre: "Proveedor Dos", contacto: "Ana Gómez" }
])

proveedores = Proveedor.create!([
  { nombre: "Distribuidor A", tipoProducto: "Electrodomésticos", direccion: "Av. Central 123", telefono: 5551234, correo: "a@correo.com" },
  { nombre: "Distribuidor B", tipoProducto: "Ropa", direccion: "Calle Norte 45", telefono: 5555678, correo: "b@correo.com" }
])

# Crear productos
products = Product.create!([
  {
    nombre: "Licuadora",
    descripcion: "Licuadora de alta velocidad",
    precio: 45.99,
    stock: 20,
    category: categories[0],
    supplier: suppliers[0]
  },
  {
    nombre: "Camisa",
    descripcion: "Camisa de algodón",
    precio: 19.50,
    stock: 50,
    category: categories[2],
    supplier: suppliers[1]
  }
])

# Crear clientes
customers = Customer.create!([
  { nombre: "Juan Pérez", telefono: "555-0101" },
  { nombre: "Laura Torres", telefono: "555-0202" }
])

# Crear compras
buys = Buy.create!([
  { customer: customers[0], fecha: Time.current },
  { customer: customers[1], fecha: Time.current }
])

# Crear detalles de compra
PurchaseDetail.create!([
  {
    buy: buys[0],
    product: products[0],
    cantidad: 2,
    preciounidad: 45.99
  },
  {
    buy: buys[1],
    product: products[1],
    cantidad: 1,
    preciounidad: 19.50
  }
])