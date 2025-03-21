json.extract! person, :id, :nombre, :apellido, :documento, :correo, :created_at, :updated_at
json.url person_url(person, format: :json)
