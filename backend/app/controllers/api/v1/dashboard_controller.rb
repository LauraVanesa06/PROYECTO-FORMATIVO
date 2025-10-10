class Api::V1::DashboardController < ApplicationController
    before_action :set_time_zone

    def finanzas
        ingresos = Purchasedetail
          .joins(:product)
          .sum('purchasedetails.cantidad * products.precio')

        # Este egreso es simulado
        egresos = 1000000

        render json: {
          ingresos: ingresos.to_i,
          egresos: egresos.to_i
        }
    end
    def ventas_periodo
        hoy = Time.zone.today
        ahora = Time.zone.now

        dia = Buy.where(fecha: hoy.all_day).count
        semana = Buy.where(fecha: ahora.all_week).count
        mes = Buy.where(fecha: ahora.all_month).count

        render json: {
          dia: dia,
          semana: semana,
          mes: mes
        }
    end
    def ventas_por_metodo_pago
        metodos = ['efectivo', 'online']

        conteos = metodos.map do |metodo|
            Buy.where('LOWER(metodo_pago) = ?', metodo.downcase).count
        end

        render json: {
            etiquetas: metodos,
            valores: conteos
        }
    end

    def ventas_por_canal
        total = Buy.count.to_f
        online     = Buy.where('LOWER(metodo_pago) = ?', 'online').count
        efectivo   = Buy.where('LOWER(metodo_pago) = ?', 'efectivo').count
        cotizadas  = Buy.where('LOWER(metodo_pago) = ?', 'cotizadas').count

        render json: {
            online:    ((online / total) * 100).round,
            efectivo:  ((efectivo / total) * 100).round,
            cotizadas: ((cotizadas / total) * 100).round
        }
    end
     def ventas_por_categoria
        datos = Category
                  .joins(products: :purchasedetails)
                  .group('categories.nombre')
                  .sum('purchasedetails.cantidad')

        render json: {
          etiquetas: datos.keys,
          valores: datos.values
        }
      end
    def porcentaje_stock
        total_stock = Product.sum(:stock)
        stock_maximo = 1000.0
        porcentaje = ((total_stock / stock_maximo) * 100).round

        render json: { porcentaje: porcentaje.clamp(0, 100) }
    end
    def clientes_por_mes
        clientes = User.where(created_at: Time.current.beginning_of_year..Time.current.end_of_year)
                        .group("strftime('%m', created_at)").count

        datos_ordenados = (1..12).map do |mes|
            mes_str = mes.to_s.rjust(2, '0')
            [mes_str, clientes[mes_str] || 0]
        end.to_h

        render json: datos_ordenados
    end

    def por_tipo
        hoy     = Buy.where(fecha: Date.current).count
        semana  = Buy.where(fecha: Date.current.beginning_of_week..Date.current.end_of_week).count
        mes     = Buy.where(fecha: Date.current.beginning_of_month..Date.current.end_of_month).count
        anio    = Buy.where(fecha: Date.current.beginning_of_year..Date.current.end_of_year).count

        render json: {
            labels: ["Hoy", "Semana", "Mes", "Año"],
            datasets: [
            {
                label: "Minorista",
                data: [
                Buy.where(fecha: Date.current, tipo: "Minorista").count,
                Buy.where(fecha: Date.current.beginning_of_week..Date.current.end_of_week, tipo: "Minorista").count,
                Buy.where(fecha: Date.current.beginning_of_month..Date.current.end_of_month, tipo: "Minorista").count,
                Buy.where(fecha: Date.current.beginning_of_year..Date.current.end_of_year, tipo: "Minorista").count
                ]
            },
            {
                label: "Mayorista",
                data: [
                Buy.where(fecha: Date.current, tipo: "Mayorista").count,
                Buy.where(fecha: Date.current.beginning_of_week..Date.current.end_of_week, tipo: "Mayorista").count,
                Buy.where(fecha: Date.current.beginning_of_month..Date.current.end_of_month, tipo: "Mayorista").count,
                Buy.where(fecha: Date.current.beginning_of_year..Date.current.end_of_year, tipo: "Mayorista").count
                ]
            },
            {
                label: "Contratista/Empresa",
                data: [
                Buy.where(fecha: Date.current, tipo: "Contratista/Empresa").count,
                Buy.where(fecha: Date.current.beginning_of_week..Date.current.end_of_week, tipo: "Contratista/Empresa").count,
                Buy.where(fecha: Date.current.beginning_of_month..Date.current.end_of_month, tipo: "Contratista/Empresa").count,
                Buy.where(fecha: Date.current.beginning_of_year..Date.current.end_of_year, tipo: "Contratista/Empresa").count
                ]
            }
            ],
            totales: {
            hoy: hoy,
            semana: semana,
            mes: mes,
            anio: anio
            }
        }
    end


    def ventas_por_dia
        ventas = Purchasedetail
        .joins(:buy)
        .group("DATE(buys.fecha)")
        .sum("preciounidad * cantidad")

        dias = {
            "Monday" => "Lunes",
            "Tuesday" => "Martes",
            "Wednesday" => "Miércoles",
            "Thursday" => "Jueves",
            "Friday" => "Viernes",
            "Saturday" => "Sábado",
            "Sunday" => "Domingo"
        }

        render json: {
        labels: ventas.keys.map { |d| dias[Date.parse(d).strftime("%A")] || d },
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

    private

    def set_time_zone
      Time.zone = 'Bogota' # Cambia a tu zona horaria local si es necesario
    end
end
