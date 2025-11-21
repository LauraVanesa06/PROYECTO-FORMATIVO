class Customer < ApplicationRecord
  # Las compras (buys) ahora están asociadas a User, no a Customer
  # Si necesitas acceder a purchasedetails, hazlo a través de User
end
