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
      # Contar ventas por tipo: Online (Wompy) vs Física
      ventas_online = Buy.where(tipo: "Online").count
      ventas_fisica = Buy.where(tipo: "Física").count

      render json: {
        etiquetas: ["Online (Wompy)", "Física"],
        valores: [ventas_online, ventas_fisica]
      }
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
