# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def reset_postgres_sequences(*tables)
  tables.each do |table|
    ActiveRecord::Base.connection.reset_pk_sequence!(table)
  end
end

puts "🧹 Limpiando base de datos..."

# 🔹 Primero elimina las tablas hijas (dependientes)
PedidoProduct.delete_all
Purchasedetail.delete_all
Buy.delete_all
Pedido.delete_all
CartItem.delete_all   # 👈 AGREGA ESTA LÍNEA ANTES DE Cart
Cart.delete_all 
Product.delete_all
Customer.delete_all
Marca.delete_all
Category.delete_all
Supplier.delete_all
User.delete_all

puts "✅ Datos eliminados, guardando datos de la semilla..."

reset_postgres_sequences(
  'purchasedetails',
  'buys',
  'products',
  'marcas',
  'categories',
  'suppliers',
  'customers',
  'users',
  'pedidos',
  'carts',
  'cart_items'
)


User.create!([
  { name: "Administrador", email: "user@gmail.com", password: "123456", role: "admin" },
  { name: "Cliente", email: "cliente@gmail.com", password: "123456", role: "user" },
])


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

# Adjuntar imagen a cada categoría si existe una imagen con su nombre en db/seeds-img
extensiones = [".jpg", ".jpeg", ".png", ".webp", ".avif"]
categories.each do |category|
  imagen_encontrada = false
  extensiones.each do |ext|
    nombre_archivo = "#{category.nombre}#{ext}"
    ruta_imagen = Rails.root.join("db/seeds-img", nombre_archivo)
    if File.exist?(ruta_imagen)
      category.imagen.attach(
        io: File.open(ruta_imagen),
        filename: nombre_archivo,
        content_type: Marcel::MimeType.for(ruta_imagen)
      )
      puts "✅ Imagen cargada para categoría #{category.nombre}"
      imagen_encontrada = true
      break
    end
  end
  puts "⚠️  Imagen no encontrada para categoría #{category.nombre}" unless imagen_encontrada
end

suppliers = Supplier.create!([
  { nombre: "Ferretería Industrial Martínez S.A. de C.V.", contacto: "5512345678", codigo_proveedor: "FIM001", correo: "contacto@fim.com" },
  { nombre: "Suministros y Herramientas del Norte", contacto: "5523456789", codigo_proveedor: "SHN002", correo: "ventas@shn.com" },
  { nombre: "Grupo Ferrecomex", contacto: "5534567896", codigo_proveedor: "GFX003", correo: "info@ferrecomex.com" },
  { nombre: "Materiales y Tornillería El Águila", contacto: "5545678901", codigo_proveedor: "MTA004", correo: "atencion@elaguila.com" },
  { nombre: "Distribuidora FerrePlus", contacto: "5556789012", codigo_proveedor: "DFP005", correo: "soporte@ferreplus.com" }
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
  # HERRAMIENTAS (6 productos)
  {
    nombre: "Martillo",
    descripcion: "Martillo de alta resistencia con mango ergonómico y cabeza de acero forjado, ideal para trabajos de carpintería, construcción y reparaciones generales.",
    precio: 25_000,
    stock: 50,
    codigo_producto: "P001",
    modelo: "MX-200",
    disponible: true,
    category: categories[0],
    supplier: suppliers[0],
    marca: marcas[1]
  },
  {
    nombre: "Destornillador Phillips",
    descripcion: "Destornillador Phillips con mango ergonómico antideslizante y punta magnética, ideal para trabajos de precisión en electrónica y carpintería.",
    precio: 12_000,
    stock: 75,
    codigo_producto: "P002",
    modelo: "DP-15",
    disponible: true,
    category: categories[0],
    supplier: suppliers[1],
    marca: marcas[0]
  },
  {
    nombre: "Alicate Universal",
    descripcion: "Alicate universal con mandíbulas dentadas y cortador lateral, fabricado en acero cromado para mayor durabilidad y resistencia.",
    precio: 28_000,
    stock: 40,
    codigo_producto: "P003",
    modelo: "AU-250",
    disponible: true,
    category: categories[0],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Llave Inglesa Ajustable",
    descripcion: "Llave inglesa ajustable de 12 pulgadas con mandíbulas templadas y mango con recubrimiento antideslizante.",
    precio: 32_000,
    stock: 35,
    codigo_producto: "P004",
    modelo: "LI-300",
    disponible: true,
    category: categories[0],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Taladro Eléctrico",
    descripcion: "Taladro eléctrico de 600W con portabrocas de 13mm y regulador de velocidad, ideal para perforaciones en múltiples materiales.",
    precio: 85_000,
    stock: 15,
    codigo_producto: "P005",
    modelo: "TE-600",
    disponible: true,
    category: categories[0],
    supplier: suppliers[0],
    marca: marcas[1]
  },
  {
    nombre: "Sierra Circular Manual",
    descripcion: "Sierra circular manual de 7¼ pulgadas con motor de 1400W y guía láser para cortes precisos en madera y derivados.",
    precio: 120_000,
    stock: 8,
    codigo_producto: "P006",
    modelo: "SC-1400",
    disponible: true,
    category: categories[0],
    supplier: suppliers[1],
    marca: marcas[2]
  },

  # TORNILLERIA Y FIJACIONES (6 productos)
  {
    nombre: "Llave combinada",
    descripcion: "Llave combinada de acero cromado con boca fija y estrella, ideal para ajustar o aflojar tuercas y pernos de forma segura y eficiente.",
    precio: 6_000,
    stock: 80,
    codigo_producto: "P007",
    modelo: "LC-14",
    disponible: true,
    category: categories[1],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Tornillos Autorroscantes",
    descripcion: "Caja de 100 tornillos autorroscantes de acero galvanizado de 3x25mm, ideales para fijación en metal y madera.",
    precio: 15_000,
    stock: 200,
    codigo_producto: "P008",
    modelo: "TA-325",
    disponible: true,
    category: categories[1],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Pernos Hexagonales",
    descripcion: "Set de 50 pernos hexagonales M8x40mm con tuercas y arandelas incluidas, fabricados en acero inoxidable.",
    precio: 25_000,
    stock: 150,
    codigo_producto: "P009",
    modelo: "PH-840",
    disponible: true,
    category: categories[1],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Remaches de Aluminio",
    descripcion: "Caja de 100 remaches de aluminio de 4mm con herramienta remachadora incluida, ideal para uniones permanentes.",
    precio: 18_000,
    stock: 120,
    codigo_producto: "P010",
    modelo: "RA-400",
    disponible: true,
    category: categories[1],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Clavos de Acero",
    descripcion: "Kilogramo de clavos de acero de 2½ pulgadas con punta diamante, ideales para carpintería y construcción general.",
    precio: 8_000,
    stock: 300,
    codigo_producto: "P011",
    modelo: "CA-25",
    disponible: true,
    category: categories[1],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Grapas para Grapadora",
    descripcion: "Caja de 5000 grapas galvanizadas de 10mm para grapadora neumática, ideales para tapicería y carpintería.",
    precio: 12_000,
    stock: 180,
    codigo_producto: "P012",
    modelo: "GG-10",
    disponible: true,
    category: categories[1],
    supplier: suppliers[1],
    marca: marcas[6]
  },

  # PLOMERIA (6 productos)
  {
    nombre: "Llave stilson",
    descripcion: "Llave Stilson de acero forjado con mango antideslizante y mordazas ajustables, ideal para sujetar y girar tuberías metálicas con firmeza y seguridad.",
    precio: 40_000,
    stock: 30,
    codigo_producto: "P013",
    modelo: "LS-10",
    disponible: true,
    category: categories[2],
    supplier: suppliers[1],
    marca: marcas[1]
  },
  {
    nombre: "Pinza de presión",
    descripcion: "Pinza de presión de acero con mecanismo de bloqueo ajustable, ideal para sujetar firmemente piezas sin esfuerzo continuo.",
    precio: 15_000,
    stock: 10,
    codigo_producto: "P014",
    modelo: "PP-05",
    disponible: true,
    category: categories[2],
    supplier: suppliers[2],
    marca: marcas[7]
  },
  {
    nombre: "Codos PVC 90°",
    descripcion: "Pack de 10 codos de PVC de 90 grados de 4 pulgadas, resistentes a la corrosión y aptos para sistemas de drenaje.",
    precio: 20_000,
    stock: 250,
    codigo_producto: "P015",
    modelo: "CP-490",
    disponible: true,
    category: categories[2],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Válvula de Bola",
    descripcion: "Válvula de bola de bronce de ½ pulgada con palanca manual, ideal para control de flujo en sistemas de agua.",
    precio: 25_000,
    stock: 80,
    codigo_producto: "P016",
    modelo: "VB-05",
    disponible: true,
    category: categories[2],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Tubo PVC Sanitario",
    descripcion: "Tubo de PVC sanitario de 4 pulgadas x 3 metros, color naranja, para sistemas de alcantarillado y drenaje.",
    precio: 35_000,
    stock: 100,
    codigo_producto: "P017",
    modelo: "TPS-43",
    disponible: true,
    category: categories[2],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Sellador de Roscas",
    descripcion: "Sellador líquido para roscas de 50ml, resistente a altas temperaturas y presiones, ideal para uniones roscadas.",
    precio: 12_000,
    stock: 150,
    codigo_producto: "P018",
    modelo: "SR-50",
    disponible: true,
    category: categories[2],
    supplier: suppliers[2],
    marca: marcas[5]
  },

  # ELECTRICIDAD (6 productos)
  {
    nombre: "Taladro atornillador inalámbrico",
    descripcion: "Taladro atornillador inalámbrico compacto Milwaukee, ideal para perforar y atornillar con potencia y precisión sin necesidad de cables.",
    precio: 90_000,
    stock: 8,
    codigo_producto: "P019",
    modelo: "TA-800",
    disponible: true,
    category: categories[3],
    supplier: suppliers[3],
    marca: marcas[8]
  },
  {
    nombre: "Multímetro Digital",
    descripcion: "Multímetro digital con pantalla LCD, medición de voltaje AC/DC, corriente, resistencia y continuidad.",
    precio: 45_000,
    stock: 25,
    codigo_producto: "P020",
    modelo: "MD-2000",
    disponible: true,
    category: categories[3],
    supplier: suppliers[0],
    marca: marcas[1]
  },
  {
    nombre: "Cable THHN 12 AWG",
    descripcion: "Rollo de 100 metros de cable THHN calibre 12 AWG, aislamiento termoplástico para instalaciones eléctricas.",
    precio: 85_000,
    stock: 50,
    codigo_producto: "P021",
    modelo: "CT-12100",
    disponible: true,
    category: categories[3],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Interruptor Termomagnético",
    descripcion: "Interruptor termomagnético bipolar de 20A, protección contra sobrecarga y cortocircuito para tableros eléctricos.",
    precio: 28_000,
    stock: 75,
    codigo_producto: "P022",
    modelo: "IT-20B",
    disponible: true,
    category: categories[3],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Canaleta Plástica",
    descripcion: "Canaleta plástica de 25x16mm x 2 metros con tapa, color blanco, para ocultar cableado en instalaciones visibles.",
    precio: 15_000,
    stock: 200,
    codigo_producto: "P023",
    modelo: "CP-2516",
    disponible: true,
    category: categories[3],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Prensa Cables",
    descripcion: "Pack de 50 prensacables plásticos de diferentes medidas (16mm, 20mm, 25mm) para entrada de cables en cajas.",
    precio: 22_000,
    stock: 120,
    codigo_producto: "P024",
    modelo: "PC-MIX",
    disponible: true,
    category: categories[3],
    supplier: suppliers[0],
    marca: marcas[6]
  },

  # CONSTRUCCION Y MATERIALES (6 productos)
  {
    nombre: "Tijera para lamina",
    descripcion: "Tijera corta hojalata con hojas de acero endurecido y mangos ergonómicos, ideal para cortar láminas de metal, aluminio y otros materiales delgados.",
    precio: 35_000,
    stock: 12,
    codigo_producto: "P025",
    modelo: "TL-22",
    disponible: true,
    category: categories[4],
    supplier: suppliers[3],
    marca: marcas[3]
  },
  {
    nombre: "Pala de punta",
    descripcion: "Pala de punta con hoja de acero resistente y mango corto de madera con agarradera en 'D', ideal para cavar, remover tierra y trabajos de jardinería o construcción.",
    precio: 25_000,
    stock: 50,
    codigo_producto: "P026",
    modelo: "PP-01",
    disponible: true,
    category: categories[4],
    supplier: suppliers[0],
    marca: marcas[4]
  },
  {
    nombre: "Cemento Portland",
    descripcion: "Saco de cemento Portland de 50kg, tipo I, ideal para construcción general, cimentaciones y estructuras.",
    precio: 22_000,
    stock: 300,
    codigo_producto: "P027",
    modelo: "CP-50",
    disponible: true,
    category: categories[4],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Varilla Corrugada",
    descripcion: "Varilla de acero corrugada de ½ pulgada x 12 metros, grado 60, para refuerzo en estructuras de concreto.",
    precio: 45_000,
    stock: 200,
    codigo_producto: "P028",
    modelo: "VC-512",
    disponible: true,
    category: categories[4],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Ladrillo Macizo",
    descripcion: "Millar de ladrillos macizos de arcilla cocida 24x11x6cm, alta resistencia para muros portantes y divisorios.",
    precio: 180_000,
    stock: 50,
    codigo_producto: "P029",
    modelo: "LM-1000",
    disponible: true,
    category: categories[4],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Arena Fina",
    descripcion: "Metro cúbico de arena fina lavada y cernida, ideal para mezclas de mortero y acabados finos en construcción.",
    precio: 35_000,
    stock: 100,
    codigo_producto: "P030",
    modelo: "AF-M3",
    disponible: true,
    category: categories[4],
    supplier: suppliers[0],
    marca: marcas[6]
  },

  # PINTURA Y ACABADOS (6 productos)
  {
    nombre: "Lima plana manual",
    descripcion: "Lima plana de acero templado con mango ergonómico, ideal para desbastar y dar forma a superficies metálicas o de madera.",
    precio: 8_000,
    stock: 150,
    codigo_producto: "P031",
    modelo: "LP-09",
    disponible: true,
    category: categories[5],
    supplier: suppliers[1],
    marca: marcas[5]
  },
  {
    nombre: "Pintura Látex Interior",
    descripcion: "Galón de pintura látex lavable para interiores, color blanco mate, rendimiento 12m²/litro, secado rápido.",
    precio: 55_000,
    stock: 80,
    codigo_producto: "P032",
    modelo: "PL-4000",
    disponible: true,
    category: categories[5],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Rodillo de Espuma",
    descripcion: "Rodillo de espuma de 9 pulgadas con mango telescópico, ideal para aplicación uniforme de pintura en superficies lisas.",
    precio: 18_000,
    stock: 120,
    codigo_producto: "P033",
    modelo: "RE-09",
    disponible: true,
    category: categories[5],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Brocha Angular",
    descripcion: "Brocha angular de 2 pulgadas con cerdas sintéticas, mango ergonómico, ideal para cortes y detalles en pintura.",
    precio: 15_000,
    stock: 100,
    codigo_producto: "P034",
    modelo: "BA-02",
    disponible: true,
    category: categories[5],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Masilla Plástica",
    descripcion: "Kilogramo de masilla plástica para reparación de grietas y huecos en paredes, fácil lijado y pintura.",
    precio: 25_000,
    stock: 90,
    codigo_producto: "P035",
    modelo: "MP-1000",
    disponible: true,
    category: categories[5],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Sellador Acrílico",
    descripcion: "Galón de sellador acrílico transparente para madera, proporciona base uniforme antes de aplicar pintura o barniz.",
    precio: 45_000,
    stock: 70,
    codigo_producto: "P036",
    modelo: "SA-4000",
    disponible: true,
    category: categories[5],
    supplier: suppliers[2],
    marca: marcas[6]
  },

  # FERRETERIA PARA EL HOGAR (6 productos)
  {
    nombre: "Esmeriladora angular inalámbrica",
    descripcion: "Esmeriladora angular inalámbrica ideal para cortar, desbastar y pulir materiales como metal, piedra o cerámica, sin depender de cables.",
    precio: 35_000,
    stock: 34,
    codigo_producto: "P037",
    modelo: "EA-500",
    disponible: true,
    category: categories[6],
    supplier: suppliers[1],
    marca: marcas[9]
  },
  {
    nombre: "Juego de Llaves Allen",
    descripcion: "Juego de 9 llaves Allen hexagonales de 1.5 a 10mm en estuche plástico, acero cromado de alta calidad.",
    precio: 20_000,
    stock: 85,
    codigo_producto: "P038",
    modelo: "JLA-09",
    disponible: true,
    category: categories[6],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Candado de Seguridad",
    descripcion: "Candado de seguridad de 50mm con arco de acero templado y 3 llaves incluidas, resistente a intemperie.",
    precio: 28_000,
    stock: 60,
    codigo_producto: "P039",
    modelo: "CS-50",
    disponible: true,
    category: categories[6],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Bisagras de Puerta",
    descripcion: "Par de bisagras de acero inoxidable de 4 pulgadas con tornillos incluidos, para puertas interiores y exteriores.",
    precio: 22_000,
    stock: 150,
    codigo_producto: "P040",
    modelo: "BP-04",
    disponible: true,
    category: categories[6],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Cerradura de Pomo",
    descripcion: "Cerradura de pomo cilíndrica con llave, acabado cromado satinado, para puertas de entrada y habitaciones.",
    precio: 65_000,
    stock: 45,
    codigo_producto: "P041",
    modelo: "CP-Chrome",
    disponible: true,
    category: categories[6],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Cinta Métrica",
    descripcion: "Cinta métrica de 5 metros con carcasa resistente a impactos, cinta de acero con freno automático.",
    precio: 15_000,
    stock: 200,
    codigo_producto: "P042",
    modelo: "CM-500",
    disponible: true,
    category: categories[6],
    supplier: suppliers[2],
    marca: marcas[0]
  },

  # LIMPIEZA Y MANTENIMIENTO (6 productos)
  {
    nombre: "Sierra",
    descripcion: "Sierra manual con hoja de acero templado y mango ergonómico, ideal para cortes precisos en madera, plástico o metal.",
    precio: 19_900,
    stock: 25,
    codigo_producto: "P043",
    modelo: "SR-15",
    disponible: true,
    category: categories[7],
    supplier: suppliers[2],
    marca: marcas[2]
  },
  {
    nombre: "Escoba Industrial",
    descripcion: "Escoba industrial con cerdas duras y mango de madera de 1.20m, ideal para limpieza de talleres y bodegas.",
    precio: 25_000,
    stock: 100,
    codigo_producto: "P044",
    modelo: "EI-120",
    disponible: true,
    category: categories[7],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Trapeador Microfibra",
    descripcion: "Trapeador de microfibra con sistema de escurrido integrado, mango telescópico ajustable de 90 a 130cm.",
    precio: 35_000,
    stock: 75,
    codigo_producto: "P045",
    modelo: "TM-Telescopico",
    disponible: true,
    category: categories[7],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Desengrasante Industrial",
    descripcion: "Galón de desengrasante industrial concentrado, biodegradable, para limpieza de maquinaria y herramientas.",
    precio: 45_000,
    stock: 60,
    codigo_producto: "P046",
    modelo: "DI-4000",
    disponible: true,
    category: categories[7],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Guantes de Nitrilo",
    descripcion: "Caja de 100 guantes de nitrilo azules, talla M, resistentes a químicos y perforaciones, uso industrial.",
    precio: 28_000,
    stock: 150,
    codigo_producto: "P047",
    modelo: "GN-100M",
    disponible: true,
    category: categories[7],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Paños Absorbentes",
    descripcion: "Pack de 50 paños absorbentes industriales de 40x30cm, reutilizables, para limpieza de aceites y líquidos.",
    precio: 22_000,
    stock: 120,
    codigo_producto: "P048",
    modelo: "PA-50",
    disponible: true,
    category: categories[7],
    supplier: suppliers[0],
    marca: marcas[6]
  },

  # ADHESIVOS Y SELLADORES (6 productos)
  {
    nombre: "Silicona Transparente",
    descripcion: "Cartucho de silicona transparente de 280ml, resistente al agua y temperaturas extremas, para uso general.",
    precio: 12_000,
    stock: 200,
    codigo_producto: "P049",
    modelo: "ST-280",
    disponible: true,
    category: categories[8],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Adhesivo Epoxi",
    descripcion: "Adhesivo epoxi bicomponente de 25ml, alta resistencia para metal, cerámica, vidrio y plásticos rígidos.",
    precio: 18_000,
    stock: 150,
    codigo_producto: "P050",
    modelo: "AE-25",
    disponible: true,
    category: categories[8],
    supplier: suppliers[3],
    marca: marcas[5]
  },
  {
    nombre: "Pegamento PVC",
    descripcion: "Frasco de pegamento para PVC de 125ml con aplicador, secado rápido, para uniones permanentes en tubería.",
    precio: 15_000,
    stock: 180,
    codigo_producto: "P051",
    modelo: "PP-125",
    disponible: true,
    category: categories[8],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Cinta Doble Cara",
    descripcion: "Rollo de cinta doble cara de espuma de 19mm x 5 metros, alta adherencia para montaje permanente.",
    precio: 20_000,
    stock: 100,
    codigo_producto: "P052",
    modelo: "CDC-195",
    disponible: true,
    category: categories[8],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Sellador Poliuretano",
    descripcion: "Cartucho de sellador de poliuretano de 300ml, elástico y paintable, para juntas de dilatación.",
    precio: 25_000,
    stock: 90,
    codigo_producto: "P053",
    modelo: "SP-300",
    disponible: true,
    category: categories[8],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Adhesivo de Contacto",
    descripcion: "Galón de adhesivo de contacto para laminados, cuero, tela y caucho, aplicación con brocha o rodillo.",
    precio: 55_000,
    stock: 65,
    codigo_producto: "P054",
    modelo: "AC-4000",
    disponible: true,
    category: categories[8],
    supplier: suppliers[3],
    marca: marcas[6]
  },

  # JARDINERIA (6 productos)
  {
    nombre: "Manguera de Jardín",
    descripcion: "Manguera de jardín de 25 metros con conectores rápidos, reforzada con malla, resistente a torsión y UV.",
    precio: 65_000,
    stock: 40,
    codigo_producto: "P055",
    modelo: "MJ-25",
    disponible: true,
    category: categories[9],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Tijeras de Podar",
    descripcion: "Tijeras de podar con hojas de acero inoxidable y mango ergonómico, apertura de corte hasta 20mm.",
    precio: 32_000,
    stock: 80,
    codigo_producto: "P056",
    modelo: "TP-20",
    disponible: true,
    category: categories[9],
    supplier: suppliers[2],
    marca: marcas[6]
  },
  {
    nombre: "Rastrillo Metálico",
    descripcion: "Rastrillo metálico de 16 dientes con mango de madera de 1.50m, ideal para recoger hojas y nivelar tierra.",
    precio: 28_000,
    stock: 60,
    codigo_producto: "P057",
    modelo: "RM-16",
    disponible: true,
    category: categories[9],
    supplier: suppliers[3],
    marca: marcas[6]
  },
  {
    nombre: "Regadera Plástica",
    descripcion: "Regadera de plástico de 10 litros con rociador desmontable y mango ergonómico, resistente a UV.",
    precio: 22_000,
    stock: 100,
    codigo_producto: "P058",
    modelo: "RP-10",
    disponible: true,
    category: categories[9],
    supplier: suppliers[0],
    marca: marcas[6]
  },
  {
    nombre: "Fertilizante Triple 15",
    descripcion: "Saco de 25kg de fertilizante NPK 15-15-15, nutrición balanceada para todo tipo de plantas y cultivos.",
    precio: 45_000,
    stock: 80,
    codigo_producto: "P059",
    modelo: "F15-25",
    disponible: true,
    category: categories[9],
    supplier: suppliers[1],
    marca: marcas[6]
  },
  {
    nombre: "Azadón de Jardín",
    descripcion: "Azadón de jardín con hoja de acero forjado y mango de madera de 90cm, ideal para cavar y remover tierra.",
    precio: 35_000,
    stock: 50,
    codigo_producto: "P060",
    modelo: "AJ-90",
    disponible: true,
    category: categories[9],
    supplier: suppliers[2],
    marca: marcas[6]
  }
])

# Limpiar imágenes existentes y cargar nuevas
puts "🖼️  Limpiando imágenes existentes de productos..."
products.each { |product| product.images.purge }

products.each do |product|
  extensiones = [".jpg", ".jpeg", ".png", ".webp", ".avif"]

  imagen_encontrada = false

  extensiones.each do |ext|
    nombre_archivo = "#{product.nombre}#{ext}"
    ruta_imagen = Rails.root.join("db/seeds-img/products", nombre_archivo)

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
    preciounidad: 26_000
  },
  {
    buy: buys[1],
    product: products[1],
    cantidad: 50,
    preciounidad: 9_500
  },
  {
    buy: buys[2],
    product: products[2],
    cantidad: 10,
    preciounidad: 30_500
  },
  {
    buy: buys[3],
    product: products[3],
    cantidad: 40,
    preciounidad: 12_500
  },
  {
    buy: buys[4],
    product: products[4],
    cantidad: 10,
    preciounidad: 17_500
  }
])


# Crear pedidos sin el campo 'productos' y asociar productos reales
pedidos = [
  {
    fecha: Time.zone.now.change(hour: 10),
    supplier: suppliers[0],
    stock: 7,
    proveedor: suppliers[0].nombre
  },
  {
    fecha: 2.days.ago.change(hour: 14),
    supplier: suppliers[1],
    stock: 4,
    proveedor: suppliers[1].nombre
  },
  {
    fecha: 1.week.ago.change(hour: 9),
    supplier: suppliers[2],
    stock: 2,
    proveedor: suppliers[2].nombre
  },
  {
    fecha: 3.weeks.ago.change(hour: 16),
    supplier: suppliers[3],
    stock: 14,
    proveedor: suppliers[3].nombre
  },
  {
    fecha: Time.zone.now.change(hour: 10),
    supplier: suppliers[0],
    stock: 7,
    proveedor: suppliers[0].nombre
  },
  {
    fecha: 2.days.ago.change(hour: 14),
    supplier: suppliers[1],
    stock: 4,
    proveedor: suppliers[1].nombre
  },
  {
    fecha: 1.week.ago.change(hour: 9),
    supplier: suppliers[2],
    stock: 2,
    proveedor: suppliers[2].nombre
  },
  {
    fecha: 3.weeks.ago.change(hour: 16),
    supplier: suppliers[3],
    stock: 14,
    proveedor: suppliers[3].nombre
  }
]

pedidos_records = pedidos.map { |attrs| Pedido.create!(attrs) }

# Asociar al menos tres productos reales a cada pedido
productos_para_asociar = Product.limit(3).to_a
pedidos_records.each_with_index do |pedido, idx|
  productos = productos_para_asociar
  # Para variedad, alternar productos si hay más de tres
  if Product.count > 3 && (Product.count - 2) > 0
    productos = Product.offset(idx % (Product.count - 2)).limit(3)
  else
    productos = Product.limit(3)
  end
  productos.each do |producto|
    PedidoProduct.create!(pedido: pedido, product_id: producto.id, cantidad: rand(1..5))
  end
end

# Agregar datos de ejemplo a los productos existentes
Product.find_each do |product|
  product.update(
    purchases_count: rand(5..100),
    buyers_count: rand(3..50)
  )
end