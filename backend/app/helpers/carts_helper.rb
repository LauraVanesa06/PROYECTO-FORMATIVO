module CartsHelper
  def cart_payment_data
    return {} unless @cart.present?

    cart_items = @cart.cart_items.includes(:product)
    total_amount = cart_items.sum { |i| (i.product&.precio || 0) * i.cantidad.to_i }
    amount_cents = (total_amount * 100).to_i
    payment_reference = "cart_#{@cart.id}_#{Time.now.to_i}"
    
    signature = if amount_cents > 0
                  WompiService.new.signature_for(
                    reference: payment_reference,
                    amount_in_cents: amount_cents
                  )
                else
                  nil
                end

    {
      amount_cents: amount_cents,
      payment_reference: payment_reference,
      signature: signature
    }
  end
end
