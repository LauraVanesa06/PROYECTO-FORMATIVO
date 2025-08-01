class Api::V1::BuysController < ApplicationController
  def por_tipo
    tipos = ['Minorista', 'Mayorista', 'Contratista/Empresa']

    hoy     = Time.zone.today.all_day
    semana  = 1.week.ago.beginning_of_day..Time.zone.now
    mes     = 1.month.ago.beginning_of_day..Time.zone.now
    año     = 1.year.ago.beginning_of_day..Time.zone.now

    datos = tipos.map do |tipo|
      {
        label: tipo,
        data: [
          Buy.where(tipo: tipo, fecha: hoy).count,
          Buy.where(tipo: tipo, fecha: semana).count,
          Buy.where(tipo: tipo, fecha: mes).count,
          Buy.where(tipo: tipo, fecha: año).count
        ],
        backgroundColor: color_para_tipo(tipo)
      }
    end

    render json: {
      labels: ['Hoy', 'Semana', 'Mes', 'Año'],
      datasets: datos
    }
  end

  private

  def color_para_tipo(tipo)
    {
      'Minorista' => '#4CAF50',
      'Mayorista' => '#66BB6A',
      'Contratista/Empresa' => '#388E3C'
    }[tipo]
  end
end
