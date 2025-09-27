json.extract! pedido, :id, :fecha, :productos, :descripcion_entrega, :supplier_id, :created_at, :updated_at
json.url pedido_url(pedido, format: :json)
