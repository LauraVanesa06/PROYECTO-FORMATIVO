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

# desactivar temporalmente las llaves foraneas
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")

puts "🧹 Limpiando base de datos..."
Purchasedetail.delete_all
Buy.delete_all
Product.delete_all
Customer.delete_all
Marca.delete_all
Category.delete_all
Supplier.delete_all
User.delete_all
Pedido.delete_all

ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
puts "✅ Datos eliminados, guardando datos de la semilla..."

reset_sqlite_sequences(
  'purchasedetails',
  'buys',
  'products',
  'marcas',
  'categories',
  'suppliers',
  'customers',
  'users',
  'pedidos'
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

marcas = Marca.create!([
  { nombre: "Stanley" },
  { nombre: "Bosch" },
  { nombre: "DeWalt" },
  { nombre: "Makita" },
  { nombre: "Black+Decker" },
  { nombre: "Hilti" },
  { nombre: "Truper" },
  { nombre: "Irwin" },
  { nombre: "Craftsman" },
  { nombre: "Milwaukee" }
])

products = Product.create!([
  {
    nombre: "Martillo",
    descripcion: "Martillo de alta resistencia con mango ergonómico y cabeza de acero forjado,
    ideal para trabajos de carpintería, construcción y reparaciones generales.",
    precio: 25000.9,
    stock: 50,
    codigo_producto: "P001",
    modelo: "MX-200",
    disponible: true,
    category: categories[0],
    supplier: suppliers[0],
    marca: marcas[1]
  },
  {
    nombre: "Llave stilson",
    descripcion: "Llave Stilson de acero forjado con mango antideslizante y mordazas ajustables,
    ideal para sujetar y girar tuberías metálicas con firmeza y seguridad.",
    precio: 40000,
    stock: 30,
    codigo_producto: "P002",
    modelo: "LS-10",
    disponible: true,
    category: categories[0],
    supplier: suppliers[1],
    marca: marcas[1]
  },
  {
    nombre: "Sierra",
    descripcion: "Sierra manual con hoja de acero templado y mango ergonómico,
    ideal para cortes precisos en madera, plástico o metal.",
    precio: 19900,
    stock: 25,
    codigo_producto: "P003",
    modelo: "SR-15",
    disponible: true,
    category: categories[2],
    supplier: suppliers[2],
    marca: marcas[2]
  },
  {
    nombre: "Tijera para lamina",
    descripcion: "Tijera corta hojalata con hojas de acero endurecido y mangos ergonómicos,
    ideal para cortar láminas de metal, aluminio y otros materiales delgados.",
    precio: 35000,
    stock: 12,
    codigo_producto: "P004",
    modelo: "TL-22",
    disponible: true,
    category: categories[4],
    supplier: suppliers[3],
    marca: marcas[3]
  },
  {
    nombre: "Pala de punta",
    descripcion: "Pala de punta con hoja de acero resistente y mango corto de madera con agarradera en “D”,
    ideal para cavar, remover tierra y trabajos de jardinería o construcción.",
    precio: 25000,
    stock: 50,
    codigo_producto: "P005",
    modelo: "PP-01",
    disponible: true,
    category: categories[1],
    supplier: suppliers[0],
    marca: marcas[4]
  },
  {
    nombre: "Lima plana manual",
    descripcion: "Lima plana de acero templado con mango ergonómico,
    ideal para desbastar y dar forma a superficies metálicas o de madera.",
    precio: 8000,
    stock: 150,
    codigo_producto: "P006",
    modelo: "LP-09",
    disponible: true,
    category: categories[5],
    supplier: suppliers[1],
    marca: marcas[5]
  },
  {
    nombre: "Llave combinada",
    descripcion: "Llave combinada de acero cromado con boca fija y estrella,
    ideal para ajustar o aflojar tuercas y pernos de forma segura y eficiente.",
    precio: 6000,
    stock: 80,
    codigo_producto: "P007",
    modelo: "LC-14",
    disponible: true,
    category: categories[1],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Pinza de presión",
    descripcion: "Pinza de presión de acero con mecanismo de bloqueo ajustable,
    ideal para sujetar firmemente piezas sin esfuerzo continuo.",
    precio: 15000,
    stock: 10,
    codigo_producto: "P008",
    modelo: "PP-05",
    disponible: true,
    category: categories[2],
    supplier: suppliers[2],
    marca: marcas[7]
  },
  {
    nombre: "Taladro atornillador inalámbrico",
    descripcion: "Taladro atornillador inalámbrico compacto Milwaukee,
    ideal para perforar y atornillar con potencia y precisión sin necesidad de cables.",
    precio: 900000,
    stock: 8,
    codigo_producto: "P009",
    modelo: "TA-800",
    disponible: true,
    category: categories[3],
    supplier: suppliers[3],
    marca: marcas[8]
  },
  {
    nombre: "Esmeriladora angular inalámbrica",
    descripcion: "Esmeriladora angular inalámbrica ideal para cortar,
    desbastar y pulir materiales como metal, piedra o cerámica, sin depender de cables.",
    precio: 350000,
    stock: 34,
    codigo_producto: "P010",
    modelo: "EA-500",
    disponible: true,
    category: categories[0],
    supplier: suppliers[1],
    marca: marcas[9]
  }
])

products.each do |product|
  extensiones = [".jpg", ".jpeg", ".png", ".webp", ".avif"]

  imagen_encontrada = false

  extensiones.each do |ext|
    nombre_archivo = "#{product.nombre}#{ext}"
    ruta_imagen = Rails.root.join("db/seeds-img", nombre_archivo)

    if File.exist?(ruta_imagen)
      product.images.attach(
        io: File.open(ruta_imagen),
        filename: nombre_archivo,
        content_type: Marcel::MimeType.for(ruta_imagen)
      )
      puts "✅ Imagen cargada para #{product.nombre}"
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
  { customer: customers[0], fecha: Time.zone.now.change(hour: 9),  tipo: "Minorista",            metodo_pago: "Efectivo" },
  { customer: customers[1], fecha: Time.zone.now.change(hour: 11), tipo: "Mayorista",            metodo_pago: "Online" },
  { customer: customers[2], fecha: Time.zone.now.change(hour: 13), tipo: "Contratista/Empresa",  metodo_pago: "Efectivo" },
  { customer: customers[2], fecha: Time.zone.now.change(hour: 13), tipo: "Contratista/Empresa",  metodo_pago: "Online" },

  { customer: customers[3], fecha: 1.day.ago.change(hour: 10),     tipo: "Minorista",            metodo_pago: "Online" },
  { customer: customers[4], fecha: 2.days.ago.change(hour: 14),    tipo: "Mayorista",            metodo_pago: "Efectivo" },
  { customer: customers[4], fecha: 2.days.ago.change(hour: 14),    tipo: "Mayorista",            metodo_pago: "Online" },
  { customer: customers[0], fecha: 3.days.ago.change(hour: 15),    tipo: "Contratista/Empresa",  metodo_pago: "Efectivo" },

  { customer: customers[1], fecha: 10.days.ago.change(hour: 11),   tipo: "Minorista",            metodo_pago: "Efectivo" },
  { customer: customers[1], fecha: 10.days.ago.change(hour: 11),   tipo: "Minorista",            metodo_pago: "Online" },
  { customer: customers[2], fecha: 15.days.ago.change(hour: 16),   tipo: "Mayorista",            metodo_pago: "Efectivo" },
  { customer: customers[3], fecha: 20.days.ago.change(hour: 12),   tipo: "Contratista/Empresa",  metodo_pago: "Online" },
  { customer: customers[3], fecha: 20.days.ago.change(hour: 12),   tipo: "Contratista/Empresa",  metodo_pago: "Efectivo" },

  { customer: customers[4], fecha: 2.months.ago.change(hour: 17),  tipo: "Minorista",            metodo_pago: "Online" },
  { customer: customers[0], fecha: 4.months.ago.change(hour: 10),  tipo: "Mayorista",            metodo_pago: "Efectivo" },
  { customer: customers[0], fecha: 4.months.ago.change(hour: 10),  tipo: "Mayorista",            metodo_pago: "Online" },
  { customer: customers[1], fecha: 5.months.ago.change(hour: 13),  tipo: "Contratista/Empresa",  metodo_pago: "Efectivo" }
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

pedidos = Pedido.create!([
  {
    fecha: Time.zone.now.change(hour: 10),
    productos: [
      { nombre: "Martillo", cantidad: 5 },
      { nombre: "Llave stilson", cantidad: 2 }
    ],
    descripcion_entrega: "Entrega en bodega principal",
    supplier: suppliers[0],
    stock: 7,
    proveedor: suppliers[0].nombre
  },
  {
    fecha: 2.days.ago.change(hour: 14),
    productos: [
      { nombre: "Sierra", cantidad: 3 },
      { nombre: "Pinza de presión", cantidad: 1 }
    ],
    descripcion_entrega: "Enviar al taller de plomería",
    supplier: suppliers[1],
    stock: 4,
    proveedor: suppliers[1].nombre
  },
  {
    fecha: 1.week.ago.change(hour: 9),
    productos: [
      { nombre: "Taladro atornillador inalámbrico", cantidad: 2 }
    ],
    descripcion_entrega: "Entrega directa al cliente",
    supplier: suppliers[2],
    stock: 2,
    proveedor: suppliers[2].nombre
  },
  {
    fecha: 3.weeks.ago.change(hour: 16),
    productos: [
      { nombre: "Esmeriladora angular inalámbrica", cantidad: 4 },
      { nombre: "Pala de punta", cantidad: 10 }
    ],
    descripcion_entrega: "Envío programado para obra en construcción",
    supplier: suppliers[3],
    stock: 14,
    proveedor: suppliers[3].nombre
  },
  {
    fecha: Time.zone.now.change(hour: 10),
    productos: [
      { nombre: "Martillo", cantidad: 5 },
      { nombre: "Llave stilson", cantidad: 2 }
    ],
    descripcion_entrega: "Entrega en bodega principal",
    supplier: suppliers[0],
    stock: 7,
    proveedor: suppliers[0].nombre
  },
  {
    fecha: 2.days.ago.change(hour: 14),
    productos: [
      { nombre: "Sierra", cantidad: 3 },
      { nombre: "Pinza de presión", cantidad: 1 }
    ],
    descripcion_entrega: "Enviar al taller de plomería",
    supplier: suppliers[1],
    stock: 4,
    proveedor: suppliers[1].nombre
  },
  {
    fecha: 1.week.ago.change(hour: 9),
    productos: [
      { nombre: "Taladro atornillador inalámbrico", cantidad: 2 }
    ],
    descripcion_entrega: "Entrega directa al cliente",
    supplier: suppliers[2],
    stock: 2,
    proveedor: suppliers[2].nombre
  },
  {
    fecha: 3.weeks.ago.change(hour: 16),
    productos: [
      { nombre: "Esmeriladora angular inalámbrica", cantidad: 4 },
      { nombre: "Pala de punta", cantidad: 10 }
    ],
    descripcion_entrega: "Envío programado para obra en construcción",
    supplier: suppliers[3],
    stock: 14,
    proveedor: suppliers[3].nombre
  }
])
