#!/usr/bin/env rails runner

# Actualizar todos los registros de Wompi a Online
resultado = Buy.where(metodo_pago: 'Wompi').update_all(metodo_pago: 'Online')
puts "Actualizados #{resultado} registros de Wompi a Online"

# Mostrar el conteo actual
puts "\nConteo actual de métodos de pago:"
puts "Online: #{Buy.where(metodo_pago: 'Online').count}"
puts "Efectivo: #{Buy.where(metodo_pago: 'Efectivo').count}"
puts "Total: #{Buy.count}"
