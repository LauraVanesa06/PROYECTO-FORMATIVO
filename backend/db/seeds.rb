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
Purchasedetail.delete_all
Buy.delete_all
Product.delete_all
Category.delete_all
Supplier.delete_all
Customer.delete_all
Proveedor.delete_all
User.delete_all

# Crear usuarios
User.create!(
  email: "user@gmail.com",
  password: "123456",
  role: "admin"
)

# Crear categorías
categories = Category.create!([
  { nombre: "Martillos" },
  { nombre: "Clavos" },
  { nombre: "Sierras" },
  { nombre: "Materiales" },
  { nombre: "Herramientas" }
])

# Crear proveedores (en inglés y español, como aparecen ambos en tu schema)
suppliers = Supplier.create!([
  { nombre: "Ferretería Industrial Martínez S.A. de C.V.", contacto: "Carlos Pérez" },
  { nombre: "Suministros y Herramientas del Norte", contacto: "Ana Gómez" },
  { nombre: "Grupo Ferrecomex", contacto: "Farith Ortiz" },
  { nombre: "Materiales y Tornillería El Águila", contacto: "Jose Torres" },
  { nombre: "Distribuidora FerrePlus", contacto: "Mario auditore" }
])

proveedores = Proveedor.create!([
  { nombre: "Distribuidor A", tipoProducto: "Herramientas", direccion: "Av. Central 123", telefono: 5551234, correo: "a@correo.com" },
  { nombre: "Distribuidor B", tipoProducto: "Materiales", direccion: "Calle Norte 45", telefono: 5555678, correo: "b@correo.com" }
])

# Crear productos
products = Product.create!([
  {
    nombre: "Martillo",
    descripcion: "Martillo de alta calidad",
    precio: 25.99,
    stock: 20,
    category: categories[0],
    supplier: suppliers[0]
  },
  {
    nombre: "Martillo2",
    descripcion: "Martillo de alta calidad",
    precio: 25.99,
    stock: 20,
    category: categories[0],
    supplier: suppliers[0]
  },
  {
    nombre: "Martillo3",
    descripcion: "Martillo de alta calidad",
    precio: 25.99,
    stock: 20,
    category: categories[0],
    supplier: suppliers[0]
  },
  {
    nombre: "Martillo4",
    descripcion: "Martillo de alta calidad",
    precio: 25.99,
    stock: 20,
    category: categories[0],
    supplier: suppliers[0]
  },
  {
    nombre: "Martillo5",
    descripcion: "Martillo de alta calidad",
    precio: 25.99,
    stock: 20,
    category: categories[0],
    supplier: suppliers[0]
  },
  {
    nombre: "Caja de clavos",
    descripcion: "Caja de clavos en gran cantidad y de buena calidad",
    precio: 9.50,
    stock: 50,
    category: categories[1],
    supplier: suppliers[1]
  },
  {
    nombre: "Caja de clavos2",
    descripcion: "Caja de clavos en gran cantidad y de buena calidad",
    precio: 9.50,
    stock: 50,
    category: categories[1],
    supplier: suppliers[1]
  },
  {
    nombre: "Caja de clavos3",
    descripcion: "Caja de clavos en gran cantidad y de buena calidad",
    precio: 9.50,
    stock: 50,
    category: categories[1],
    supplier: suppliers[1]
  },
  {
    nombre: "Caja de clavos4",
    descripcion: "Caja de clavos en gran cantidad y de buena calidad",
    precio: 9.50,
    stock: 50,
    category: categories[1],
    supplier: suppliers[1]
  },
  {
    nombre: "Caja de clavos5",
    descripcion: "Caja de clavos en gran cantidad y de buena calidad",
    precio: 9.50,
    stock: 50,
    category: categories[1],
    supplier: suppliers[1]
  },
  {
    nombre: "Sierra",
    descripcion: "Sierra para usar en todo lo que necesite",
    precio: 30.50,
    stock: 50,
    category: categories[2],
    supplier: suppliers[2]
  },
  {
    nombre: "Sierra2",
    descripcion: "Sierra para usar en todo lo que necesite",
    precio: 30.50,
    stock: 50,
    category: categories[2],
    supplier: suppliers[2]
  },
  {
    nombre: "Sierra3",
    descripcion: "Sierra para usar en todo lo que necesite",
    precio: 30.50,
    stock: 50,
    category: categories[2],
    supplier: suppliers[2]
  },
  {
    nombre: "Sierra4",
    descripcion: "Sierra para usar en todo lo que necesite",
    precio: 30.50,
    stock: 50,
    category: categories[2],
    supplier: suppliers[2]
  },
  {
    nombre: "Sierra5",
    descripcion: "Sierra para usar en todo lo que necesite",
    precio: 30.50,
    stock: 50,
    category: categories[2],
    supplier: suppliers[2]
  },
  {
    nombre: "Madera",
    descripcion: "Tablas de madera para lo que necesite hacer",
    precio: 12.50,
    stock: 50,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Madera2",
    descripcion: "Tablas de madera para lo que necesite hacer",
    precio: 12.50,
    stock: 50,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Madera3",
    descripcion: "Tablas de madera para lo que necesite hacer",
    precio: 12.50,
    stock: 50,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Madera4",
    descripcion: "Tablas de madera para lo que necesite hacer",
    precio: 12.50,
    stock: 50,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Madera5",
    descripcion: "Tablas de madera para lo que necesite hacer",
    precio: 12.50,
    stock: 50,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Cinta metrica",
    descripcion: "Una herramienta util que no debe faltar",
    precio: 17.50,
    stock: 50,
    category: categories[4],
    supplier: suppliers[4]
  },
  {
    nombre: "Cinta metrica2",
    descripcion: "Una herramienta util que no debe faltar",
    precio: 17.50,
    stock: 50,
    category: categories[4],
    supplier: suppliers[4]
  },
  {
    nombre: "Cinta metrica3",
    descripcion: "Una herramienta util que no debe faltar",
    precio: 17.50,
    stock: 50,
    category: categories[4],
    supplier: suppliers[4]
  },
  {
    nombre: "Cinta metrica4",
    descripcion: "Una herramienta util que no debe faltar",
    precio: 17.50,
    stock: 50,
    category: categories[4],
    supplier: suppliers[4]
  },
  {
    nombre: "Cinta metrica5",
    descripcion: "Una herramienta util que no debe faltar",
    precio: 17.50,
    stock: 50,
    category: categories[4],
    supplier: suppliers[4]
  }
])

# Crear clientes
customers = Customer.create!([
  { nombre: "Juan Pérez", telefono: "555-0101" },
  { nombre: "Laura Torres", telefono: "555-0202" },
  { nombre: "Carlos Sanchez", telefono: "555-0107" },
  { nombre: "Michael Jackson", telefono: "555-0502" },
  { nombre: "Falcao Torres", telefono: "555-0121" }
])

# Crear compras
buys = Buy.create!([
  { customer: customers[0], fecha: Time.current },
  { customer: customers[1], fecha: Time.current },
  { customer: customers[2], fecha: Time.current },
  { customer: customers[3], fecha: Time.current },
  { customer: customers[4], fecha: Time.current },
])

# Crear detalles de compra
Purchasedetail.create!([
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