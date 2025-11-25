#!/usr/bin/env rails runner

# Script para verificar las imágenes de los productos

puts "=== VERIFICAR IMÁGENES DE PRODUCTOS ==="
puts ""

# Contar productos
total_products = Product.count
puts "Total de productos: #{total_products}"
puts ""

# Contar productos con imágenes
products_with_images = Product.joins(:blob_attachments).select("DISTINCT products.id").count
puts "Productos con imágenes: #{products_with_images}"
puts ""

# Mostrar primeros 5 productos y sus imágenes
puts "Primeros 5 productos:"
Product.limit(5).each_with_index do |product, index|
  puts "\n#{index + 1}. #{product.nombre} (ID: #{product.id})"
  if product.images.attached?
    puts "   ✓ Imágenes: #{product.images.count}"
    product.images.each_with_index do |image, img_index|
      puts "     - #{img_index + 1}. #{image.filename} (#{image.byte_size} bytes)"
    end
  else
    puts "   ✗ Sin imágenes"
  end
end

puts "\n=== FIN DEL REPORTE ==="
