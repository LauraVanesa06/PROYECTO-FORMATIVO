namespace :images do
  desc "Asignar imágenes de demostración a productos"
  task seed_demo_images: :environment do
    puts "🖼️  Asignando imágenes de demostración a productos..."

    # URLs de imágenes de ejemplo (herramientas de ferretería)
    image_urls = [
      "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=300&h=300&fit=crop", # Martillo
      "https://images.unsplash.com/photo-1578563867193-e1217b6fa57e?w=300&h=300&fit=crop", # Destornillador
      "https://images.unsplash.com/photo-1586432370695-c3410ca199e8?w=300&h=300&fit=crop", # Taladro
      "https://images.unsplash.com/photo-1565214566913-e6c6ff5ec342?w=300&h=300&fit=crop", # Nivel
      "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=300&h=300&fit=crop", # Medidor
      "https://images.unsplash.com/photo-1517420879087-5d1d12bec4d0?w=300&h=300&fit=crop", # Llave inglesa
      "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=300&h=300&fit=crop", # Sierra
      "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=300&fit=crop", # Tuerca
      "https://images.unsplash.com/photo-1587288541881-84c8b5b20d60?w=300&h=300&fit=crop", # Tornillo
      "https://images.unsplash.com/photo-1544932503-5165f3c7d3f9?w=300&h=300&fit=crop", # Pintura
    ]

    require "open-uri"

    Product.find_each do |product|
      # Saltar si ya tiene imágenes
      next if product.images.attached?

      # Seleccionar una URL aleatoria
      url = image_urls.sample

      begin
        # Descargar la imagen
        image_data = URI.open(url)
        
        # Adjuntar al producto
        product.images.attach(
          io: image_data,
          filename: "#{product.nombre.parameterize}-#{SecureRandom.hex(4)}.jpg",
          content_type: "image/jpeg"
        )

        puts "✓ Imagen agregada a: #{product.nombre}"
      rescue => e
        puts "✗ Error al agregar imagen a #{product.nombre}: #{e.message}"
      end
    end

    puts "\n✅ ¡Listo! Se asignaron imágenes de demostración a los productos."
  end
end
