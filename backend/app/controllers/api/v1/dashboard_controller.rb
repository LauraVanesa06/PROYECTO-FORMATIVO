class Api::V1::DashboardController < ApplicationController
    def ventas_por_dia
        ventas = Purchasedetail
        .joins(:buy)
        .group("DATE(buys.fecha)")
        .sum("preciounidad * cantidad")

        render json: {
        labels: ventas.keys.map { |d| I18n.l(Date.parse(d), format: "%A") },
        valores: ventas.values
        }
    end 
    def inventario_por_categoria
        data = Product.joins(:category)
                        .group("categories.nombre")
                        .sum(:stock)

        render json: {
            labels: data.keys,
            valores: data.values
        }
    end
    def ventas_mensuales
        ventas = Purchasedetail.joins(:buy)
            .group("strftime('%m', buys.fecha)")
            .sum('preciounidad * cantidad')

        meses_es = {
            "01" => "Enero", "02" => "Febrero", "03" => "Marzo",
            "04" => "Abril", "05" => "Mayo", "06" => "Junio",
            "07" => "Julio", "08" => "Agosto", "09" => "Septiembre",
            "10" => "Octubre", "11" => "Noviembre", "12" => "Diciembre"
        }

        datos_ordenados = ventas.sort.to_h

        render json: {
            labels: datos_ordenados.keys.map { |num| meses_es[num] },
            valores: datos_ordenados.values
        }
    end
    def resumen
        render json: {
        productos_en_stock: Product.sum(:stock),
        ventas_hoy: Purchasedetail.joins(:buy)
                        .where('date(buys.fecha) = ?', Date.today)
                        .sum('preciounidad * cantidad'),
        proveedores_registrados: Supplier.count,
        clientes_registrados: Customer.count
        }
    end
end
