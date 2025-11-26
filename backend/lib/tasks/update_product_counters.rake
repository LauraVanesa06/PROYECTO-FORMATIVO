namespace :products do
  desc "Actualizar los contadores de purchases_count y buyers_count basándose en las compras existentes"
  task update_counters: :environment do
    puts "Actualizando contadores de productos..."
    
    Product.find_each do |product|
      # Contar el número de veces que fue comprado
      purchases = Purchasedetail.where(product_id: product.id).count
      
      # Contar el número de clientes únicos que lo compraron
      unique_buyers = Purchasedetail.joins(:buy)
                                    .where(product_id: product.id)
                                    .distinct
                                    .pluck(:user_id)
                                    .count
      
      # Actualizar los contadores
      product.update_columns(purchases_count: purchases, buyers_count: unique_buyers)
      puts "✓ #{product.nombre}: #{purchases} compras, #{unique_buyers} compradores"
    end
    
    puts "\n✅ Contadores actualizados correctamente"
  end
end
