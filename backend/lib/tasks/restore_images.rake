namespace :images do
  desc "Restaurar imágenes originales de storage"
  task restore_original: :environment do
    puts "🔄 Restaurando imágenes originales..."
    
    # Primero, obtener lista de todos los archivos en storage
    storage_dir = Rails.root.join("storage")
    
    # Buscar todos los archivos de imagen
    image_files = Dir.glob("#{storage_dir}/**/*").select { |f| File.file?(f) && f.match?(/\.(jpg|jpeg|png|webp)$/i) }
    
    puts "Archivos encontrados en storage: #{image_files.count}"
    image_files.first(10).each { |f| puts "  - #{File.basename(f)}" }
    
    # Obtener información de los blobs
    blobs = ActiveStorage::Blob.all
    puts "\nBlobs en base de datos: #{blobs.count}"
    
    blobs.each do |blob|
      # Encontrar el archivo físico
      blob_key = blob.key
      puts "\nBlob: #{blob.filename}"
      puts "  Key: #{blob_key}"
      puts "  Size: #{blob.byte_size} bytes"
      
      # Mostrar attachments vinculados
      attachments = blob.attachments
      puts "  Attachments: #{attachments.count}"
      attachments.each do |att|
        puts "    - #{att.record_type}: #{att.record.try(:nombre) || att.record.id}"
      end
    end
  end
end
