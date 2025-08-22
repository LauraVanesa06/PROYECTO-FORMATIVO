class Api::V1::BuysController < ApplicationController
  def ventas_por_tipo
    hoy     = Time.zone.today
    semana  = hoy.beginning_of_week..hoy.end_of_week
    mes     = hoy.beginning_of_month..hoy.end_of_month
    anio    = hoy.beginning_of_year..hoy.end_of_year

    tipos = ["Minorista", "Mayorista", "Contratista/Empresa"]
    datos = {
      labels: ["Hoy", "Semana", "Mes", "Año"],
      datasets: []
    }

    tipos.each do |tipo|
      datos[:datasets] << {
        label: tipo,
        data: [
          Buy.where(tipo: tipo, fecha: hoy.all_day).count,
          Buy.where(tipo: tipo, fecha: semana).count,
          Buy.where(tipo: tipo, fecha: mes).count,
          Buy.where(tipo: tipo, fecha: anio).count
        ],
        backgroundColor: tipo_color(tipo)
      }
    end

    render json: datos
  end

  private

      def tipo_color(tipo)
        case tipo
        when "Minorista"
          "#E0A461"       # Verde pasto oscuro
        when "Mayorista"
          "#C08D7B"       # Marrón claro
        when "Contratista/Empresa"
          "#97683B"       # Gris metálico
        else
          "#BDBDBD"       # Gris neutro por defecto
        end
      end
end
