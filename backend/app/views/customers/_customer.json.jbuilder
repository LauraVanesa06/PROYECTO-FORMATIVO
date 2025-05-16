json.extract! customer, :id, :name, :telephone, :created_at, :updated_at
json.url customer_url(customer, format: :json)
