namespace :data do
  desc "Agregar datos de prueba para métodos de pago"
  task add_payment_methods: :environment do
    # Primero, actualizar Wompi a Online
    updated = Buy.where(metodo_pago: 'Wompi').update_all(metodo_pago: 'Online')
    puts "✓ Actualizados #{updated} registros de Wompi a Online"

    # Verificar si hay datos
    online_count = Buy.where(metodo_pago: 'Online').count
    efectivo_count = Buy.where(metodo_pago: 'Efectivo').count

    puts "\nConteo actual:"
    puts "  Online: #{online_count}"
    puts "  Efectivo: #{efectivo_count}"
    puts "  Total: #{Buy.count}"

    # Si no hay datos de efectivo, crear algunos de prueba
    if efectivo_count == 0 && online_count > 0
      puts "\nCreando datos de prueba para Efectivo..."
      user = User.first
      if user
        # Crear 3 compras en efectivo
        3.times do |i|
          buy = Buy.create!(
            user_id: user.id,
            fecha: Time.current - i.days,
            tipo: "Minorista",
            metodo_pago: "Efectivo",
            total: 50000 + (i * 10000)
          )
          puts "  ✓ Creada compra en Efectivo: #{buy.id}"
        end
      end
    end
  end
end
