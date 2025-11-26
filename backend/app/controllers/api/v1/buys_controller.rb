class Api::V1::BuysController < ApplicationController
    before_action :authenticate_user_from_token!, except: [:ventas_por_tipo]
    def create


      cart = current_user.cart
      return render json: { error: "Carrito vacío" }, status: 400 if cart.cart_items.empty?

      buy = Buy.create!(user: current_user)

      cart.cart_items.each do |item|
        product = item.product

        if product.stock < item.cantidad
          return render json: { error: "Stock insuficiente para #{product.name}" }, status: 422
        end

       product.update!(stock: product.stock - item.cantidad)

        # ✅ Crea relación compra-producto
        PurchaseDetail.create!(
          buy: buy,
          product: product,
          cantidad: item.cantidad,
          preciounidad: product.price
        )
      end
      cart.cart_items.destroy_all

    render json: { message: "Compra registrada correctamente", buy_id: buy.id }, status: 201


    end

  def ventas_por_tipo
    begin
      hoy     = Time.zone.today
      semana  = hoy.beginning_of_week..hoy.end_of_week
      mes     = hoy.beginning_of_month..hoy.end_of_month
      anio    = hoy.beginning_of_year..hoy.end_of_year

      tipos = ["Minorista", "Mayorista", "Contratista/Empresa", "Online", "Física"]
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
    rescue => e
      Rails.logger.error("Error en ventas_por_tipo: #{e.message}")
      render json: { error: e.message }, status: 500
    end
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
        when "Online"
          "#4472B8"       # Azul
        when "Física"
          "#70AD47"       # Verde
        else
          "#BDBDBD"       # Gris neutro por defecto
        end
      end
end
