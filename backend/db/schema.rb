# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_21_204107) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "buys", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.datetime "fecha"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tipo"
    t.string "metodo_pago"
    t.index ["customer_id"], name: "index_buys_on_customer_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "product_id", null: false
    t.integer "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "nombre"
    t.string "telefono"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "documento"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "marcas", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

create_table "payments", force: :cascade do |t|

  create_table "payments", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.string "transaction_id"
    t.integer "status", default: 0
    t.decimal "amount", precision: 12, scale: 2
    t.string "pay_method"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_payments_on_cart_id"
  end

  
  create_table "pedido_products", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "pedido_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cantidad"
    t.index ["pedido_id"], name: "index_pedido_products_on_pedido_id"
    t.index ["product_id"], name: "index_pedido_products_on_product_id"
  end

  create_table "pedidos", force: :cascade do |t|
    t.datetime "fecha"
    t.json "productos"
    t.string "descripcion_entrega"
    t.integer "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stock"
    t.string "proveedor"
    t.index ["supplier_id"], name: "index_pedidos_on_supplier_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "nombre"
    t.string "descripcion"
    t.decimal "precio", precision: 12, scale: 2
    t.integer "stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id", null: false
    t.integer "supplier_id", null: false
    t.boolean "disponible", default: true
    t.string "codigo_producto", null: false
    t.string "modelo"
    t.integer "marca_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["codigo_producto"], name: "index_products_on_codigo_producto", unique: true
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "purchasedetails", force: :cascade do |t|
    t.integer "buy_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cantidad"
    t.decimal "preciounidad"
    t.index ["buy_id"], name: "index_purchasedetails_on_buy_id"
    t.index ["product_id"], name: "index_purchasedetails_on_product_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "nombre"
    t.string "contacto"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "codigo_proveedor"
    t.index ["codigo_proveedor"], name: "index_suppliers_on_codigo_proveedor", unique: true
  end

  create_table "support_requests", force: :cascade do |t|
    t.string "user_name"
    t.string "user_email"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_supports", force: :cascade do |t|
    t.string "user_name"
    t.string "user_apellido"
    t.string "user_email"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "buys", "customers"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "favorites", "products"
  add_foreign_key "favorites", "users"
    add_foreign_key "payments", "carts"
  add_foreign_key "payments", "carts"

  add_foreign_key "pedido_products", "pedidos"
  add_foreign_key "pedido_products", "products"
  add_foreign_key "pedidos", "suppliers"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "marcas"
  add_foreign_key "products", "suppliers"
  add_foreign_key "purchasedetails", "buys", on_delete: :cascade
  add_foreign_key "purchasedetails", "products", on_delete: :cascade
end
