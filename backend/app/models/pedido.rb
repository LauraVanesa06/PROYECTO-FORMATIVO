class Pedido < ApplicationRecord
  belongs_to :supplier
  
  has_many :pedido_products
  has_many :products, through: :pedido_products
  # serialize :productos, JSON

  after_create :actualizar_stock_productos

  private

  def actualizar_stock_productos
    productos.each do |p|
      # Buscar si existe el producto
      producto = Product.find_by(id: p["product_id"])

      if producto.present?
        # Si existe, sumamos stock
        producto.increment!(:stock, p["stock"].to_i)
      else
        # Si NO existe, puedes mostrar un log o dar opción a crearlo
        Rails.logger.info "Producto no encontrado: #{p["nombre"]}. Considera crearlo."
      end
    end
  end
end
