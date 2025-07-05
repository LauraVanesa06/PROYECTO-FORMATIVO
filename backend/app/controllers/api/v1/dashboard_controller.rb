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
end
