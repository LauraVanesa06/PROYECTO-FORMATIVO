namespace :images do
  desc "Reintentar vincular imágenes antiguas a productos"
  task relink_old: :environment do
    puts "🔗 Revinculando imágenes antiguas..."
    
    # Obtener todos los blobs (imágenes)
    all_blobs = ActiveStorage::Blob.all
    
    # Obtener todos los attachments
    all_attachments = ActiveStorage::Attachment.all
    
    puts "Total de blobs: #{all_blobs.count}"
    puts "Total de attachments: #{all_attachments.count}"
    
    # Revisar qué productos NO tienen imágenes
    products_without_images = Product.where.not(id: Product.joins(:active_storage_attachments).select(:id))
    
    puts "\nProductos SIN imágenes: #{products_without_images.count}"
    
    # Mostrar los primeros 10 productos sin imágenes
    puts "\nPrimeros 10 productos sin imágenes:"
    products_without_images.limit(10).each do |product|
      puts "  - #{product.id}: #{product.nombre}"
    end
    
    # Mostrar los attachments existentes con sus productos
    puts "\n\nAttachments existentes:"
    ActiveStorage::Attachment.all.each do |att|
      blob = att.blob
      record = att.record
      puts "  #{blob.filename} → #{record.class}: #{record.try(:nombre) || record.id}"
    end
  end
end
