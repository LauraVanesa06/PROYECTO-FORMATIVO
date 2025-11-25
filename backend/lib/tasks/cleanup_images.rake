namespace :images do
  desc "Purgar imágenes nuevas y mantener las antiguas"
  task cleanup: :environment do
    puts "🧹 Limpiando imágenes..."
    
    # Las imágenes que cargué hoy tienen names como "destornillador-phillips-xxxx.jpg" (con producto-xxxx)
    # Las antiguas probablemente tienen otros nombres
    
    # Obtener fecha de hace 1 hora (cuando cargué las nuevas)
    one_hour_ago = 1.hour.ago
    
    recent_blobs = ActiveStorage::Blob.where("created_at > ?", one_hour_ago)
    
    puts "Imágenes cargadas recientemente (últimas 2 horas): #{recent_blobs.count}"
    
    removed_count = 0
    recent_blobs.each do |blob|
      puts "  Removiendo: #{blob.filename}"
      blob.purge
      removed_count += 1
    end
    
    puts "\n✓ Se removieron #{removed_count} imágenes recientes"
    
    # Mostrar imágenes que quedan
    remaining = ActiveStorage::Blob.all
    puts "\nImágenes restantes: #{remaining.count}"
    remaining.each do |blob|
      puts "  - #{blob.filename} (#{blob.byte_size} bytes)"
    end
  end
end
