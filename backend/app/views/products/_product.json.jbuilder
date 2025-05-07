json.extract! product, :id, :nombre, :descripcion, :precio, :stock, :category_id_id, :supplier_id_id, :created_at, :updated_at
json.url product_url(product, format: :json)
