# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def reset_sqlite_sequences(*tables)
  tables.each do |table|
    ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='#{table}'")
  end
end

Purchasedetail.delete_all
Buy.delete_all
Product.delete_all
Category.delete_all
Supplier.delete_all
Customer.delete_all
Proveedor.delete_all
User.delete_all

reset_sqlite_sequences(
  'purchasedetails',
  'buys',
  'products',
  'categories',
  'suppliers',
  'customers',
  'proveedores',
  'users'
)

User.create!(
  email: "user@gmail.com",
  password: "123456",
  role: "admin"
)

categories = Category.create!([
  { nombre: "Herramientas" },
  { nombre: "Tornilleria y Fijaciones" },
  { nombre: "Plomeria" },
  { nombre: "Electricidad" },
  { nombre: "Construccion y Materiales" },
  { nombre: "Pintura y Acabados" },
  { nombre: "Ferreteria para el hogar" },
  { nombre: "Limpieza y Mantenimiento" },
  { nombre: "Adhesivos y Selladores" },
  { nombre: "Jardineria" },
])

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

products = Product.create!([
  {
    nombre: "Martillo",
    descripcion: "Martillo de alta resistencia con mango ergonómico y cabeza de acero forjado,
    ideal para trabajos de carpintería, construcción y reparaciones generales.",
    precio: 25.000,
    stock: 50,
    category: categories[1],
    supplier: suppliers[1]
  },
  {
    nombre: "Llave stilson",
    descripcion: "Llave Stilson de acero forjado con mango antideslizante y mordazas ajustables,
    ideal para sujetar y girar tuberías metálicas con firmeza y seguridad.",
    precio: 40.000,
    stock: 30,
    category: categories[1],
    supplier: suppliers[2]
  },
  {
    nombre: "Sierra",
    descripcion: "Sierra manual con hoja de acero templado y mango ergonómico,
    ideal para cortes precisos en madera, plástico o metal.",
    precio: 19.900,
    stock: 25,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Tijera para lamina",
    descripcion: "Tijera corta hojalata con hojas de acero endurecido y mangos ergonómicos,
    ideal para cortar láminas de metal, aluminio y otros materiales delgados.",
    precio: 35.000,
    stock: 12,
    category: categories[5],
    supplier: suppliers[4]
  },
  {
    nombre: "Pala de punta",
    descripcion: "Pala de punta con hoja de acero resistente y mango corto de madera con agarradera en “D”,
    ideal para cavar, remover tierra y trabajos de jardinería o construcción.",
    precio: 25.000,
    stock: 50,
    category: categories[2],
    supplier: suppliers[0]
  },
  {
    nombre: "Lima plana manual",
    descripcion: "Lima plana de acero templado con mango ergonómico,
    ideal para desbastar y dar forma a superficies metálicas o de madera.",
    precio: 8.000,
    stock: 150,
    category: categories[6],
    supplier: suppliers[1]
  },
  {
    nombre: "Llave combinada",
    descripcion: "Llave combinada de acero cromado con boca fija y estrella,
    ideal para ajustar o aflojar tuercas y pernos de forma segura y eficiente.",
    precio: 6.000,
    stock: 80,
    category: categories[2],
    supplier: suppliers[0]
  },
  {
    nombre: "Pinza de presión",
    descripcion: "Pinza de presión de acero con mecanismo de bloqueo ajustable,
    ideal para sujetar firmemente piezas sin esfuerzo continuo.",
    precio: 15.000,
    stock: 10,
    category: categories[3],
    supplier: suppliers[3]
  },
  {
    nombre: "Taladro atornillador inalámbrico",
    descripcion: "Taladro atornillador inalámbrico compacto Milwaukee,
    ideal para perforar y atornillar con potencia y precisión sin necesidad de cables.",
    precio: 900.000,
    stock: 8,
    category: categories[4],
    supplier: suppliers[4]
  },
  {
    nombre: "Esmeriladora angular inalámbrica",
    descripcion: "Esmeriladora angular inalámbrica ideal para cortar,
    desbastar y pulir materiales como metal, piedra o cerámica, sin depender de cables.",
    precio: 350.000,
    stock: 34,
    category: categories[1],
    supplier: suppliers[2]
  }
])

products.each do |product|
  # Lista de extensiones posibles
  extensiones = [".jpg", ".jpeg", ".png", ".webp", "avif"]

  imagen_encontrada = false

  extensiones.each do |ext|
    nombre_archivo = "#{product.nombre}#{ext}"
    ruta_imagen = Rails.root.join("db/seeds-img", nombre_archivo)

    if File.exist?(ruta_imagen)
      product.imagen.attach(
        io: File.open(ruta_imagen),
        filename: nombre_archivo,
        content_type: Marcel::MimeType.for(ruta_imagen)
      )
      puts "✅ Imagen cargada para #{product.nombre} (#{ext})"
      imagen_encontrada = true
      break
    end
  end
  puts "⚠️  Imagen no encontrada para #{product.nombre}" unless imagen_encontrada
end

customers = Customer.create!([
  { nombre: "Juan Pérez", telefono: "555-0101", documento: 123456789 },
  { nombre: "Laura Torres", telefono: "555-0202", documento: 345678912 },
  { nombre: "Carlos Sanchez", telefono: "555-0107", documento: 678912345 },
  { nombre: "Michael Jackson", telefono: "555-0502", documento: 891234567},
  { nombre: "Falcao Torres", telefono: "555-0121", documento: 987654321 }
])

buys = Buy.create!([
  { customer: customers[0], fecha: Time.zone.now.change(hour: 9), tipo: "Minorista" },
  { customer: customers[1], fecha: Time.zone.now.change(hour: 11), tipo: "Mayorista" },
  { customer: customers[2], fecha: Time.zone.now.change(hour: 13), tipo: "Contratista/Empresa" },
  { customer: customers[2], fecha: Time.zone.now.change(hour: 13), tipo: "Contratista/Empresa" },

  { customer: customers[3], fecha: 1.day.ago.change(hour: 10), tipo: "Minorista" },
  { customer: customers[4], fecha: 2.days.ago.change(hour: 14), tipo: "Mayorista" },
  { customer: customers[4], fecha: 2.days.ago.change(hour: 14), tipo: "Mayorista" },
  { customer: customers[0], fecha: 3.days.ago.change(hour: 15), tipo: "Contratista/Empresa" },

  { customer: customers[1], fecha: 10.days.ago.change(hour: 11), tipo: "Minorista" },
  { customer: customers[1], fecha: 10.days.ago.change(hour: 11), tipo: "Minorista" },
  { customer: customers[2], fecha: 15.days.ago.change(hour: 16), tipo: "Mayorista" },
  { customer: customers[3], fecha: 20.days.ago.change(hour: 12), tipo: "Contratista/Empresa" },
  { customer: customers[3], fecha: 20.days.ago.change(hour: 12), tipo: "Contratista/Empresa" },

  { customer: customers[4], fecha: 2.months.ago.change(hour: 17), tipo: "Minorista" },
  { customer: customers[0], fecha: 4.months.ago.change(hour: 10), tipo: "Mayorista" },
  { customer: customers[0], fecha: 4.months.ago.change(hour: 10), tipo: "Mayorista" },
  { customer: customers[1], fecha: 5.months.ago.change(hour: 13), tipo: "Contratista/Empresa" }
])

Purchasedetail.create!([
  {
    buy: buys[0],
    product: products[0],
    cantidad: 20,
    preciounidad: 25.99
  },
  {
    buy: buys[1],
    product: products[1],
    cantidad: 50,
    preciounidad: 9.50
  },
  {
    buy: buys[2],
    product: products[2],
    cantidad: 10,
    preciounidad: 30.50
  },
  {
    buy: buys[3],
    product: products[3],
    cantidad: 40,
    preciounidad: 12.50
  },
  {
    buy: buys[4],
    product: products[4],
    cantidad: 10,
    preciounidad: 17.50
  }
])