class Category < ApplicationRecord
  has_many :products
  has_one_attached :imagen   # 👈 logo/imagen de la categoría

  # Invalidar caché cuando se crea, actualiza o elimina una categoría
  after_commit :invalidate_cache

  private

  def invalidate_cache
    Rails.cache.delete("categories:all")
  end
end
