namespace :images do
  desc "Ver todas las imágenes en storage"
  task list: :environment do
    puts "=== IMÁGENES EN ACTIVE STORAGE ==="
    puts ""
    
    ActiveStorage::Blob.all.limit(20).each_with_index do |blob, index|
      puts "#{index + 1}. #{blob.filename} (#{blob.byte_size} bytes)"
    end
    
    total = ActiveStorage::Blob.count
    puts "\nTotal de blobs: #{total}"
  end
end
