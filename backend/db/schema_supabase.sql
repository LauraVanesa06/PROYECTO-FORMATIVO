
-- Archivo generado desde schema.rb para migración a Supabase (PostgreSQL)
-- Respeta los nombres originales

CREATE TABLE active_storage_blobs (
    id SERIAL PRIMARY KEY,
    key VARCHAR NOT NULL UNIQUE,
    filename VARCHAR NOT NULL,
    content_type VARCHAR,
    metadata TEXT,
    service_name VARCHAR NOT NULL,
    byte_size BIGINT NOT NULL,
    checksum VARCHAR,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE active_storage_attachments (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    record_type VARCHAR NOT NULL,
    record_id BIGINT NOT NULL,
    blob_id BIGINT NOT NULL REFERENCES active_storage_blobs(id),
    created_at TIMESTAMP NOT NULL,
    UNIQUE(record_type, record_id, name, blob_id)
);

CREATE TABLE active_storage_variant_records (
    id SERIAL PRIMARY KEY,
    blob_id BIGINT NOT NULL REFERENCES active_storage_blobs(id),
    variation_digest VARCHAR NOT NULL,
    UNIQUE(blob_id, variation_digest)
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    telefono VARCHAR,
    documento INTEGER,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    contacto VARCHAR,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    descripcion VARCHAR,
    precio DECIMAL,
    stock INTEGER,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE buys (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    fecha TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE purchasedetails (
    id SERIAL PRIMARY KEY,
    buy_id INTEGER NOT NULL REFERENCES buys(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    cantidad INTEGER,
    preciounidad DECIMAL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE proveedores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    tipoProducto VARCHAR,
    direccion VARCHAR,
    telefono INTEGER,
    correo VARCHAR,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE support_requests (
    id SERIAL PRIMARY KEY,
    user_name VARCHAR,
    user_email VARCHAR,
    description TEXT,
    status VARCHAR,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR NOT NULL DEFAULT '' UNIQUE,
    encrypted_password VARCHAR NOT NULL DEFAULT '',
    reset_password_token VARCHAR UNIQUE,
    reset_password_sent_at TIMESTAMP,
    remember_created_at TIMESTAMP,
    role VARCHAR DEFAULT 'user',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
