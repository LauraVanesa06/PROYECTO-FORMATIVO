class PaymentsController < ApplicationController

  protect_from_forgery except: :webhook
  def new
    @payment = Payment.new(
       cart: current_cart,
      amount: current_cart.total,
    
    )
  end

  def status
  end

  def checkout
  end



  def webhook
    data = JSON.parse(request.body.read)
    transaction = data["data"]["transaction"]

    payment = Payment.find_by(transaction_id: transaction["id"])
    if payment
      payment.update(status: transaction["status"])
    end

    head :ok
  end
def create
  @payment = Payment.new(payment_params.merge(cart: current_cart, amount: current_cart.total))

  if @payment.save
    # Aquí podrías validar con Wompi que el pago fue exitoso
    PaymentMailer.invoice(@payment).deliver_later

    flash[:notice] = "¡Gracias por tu compra! Tu pedido llegará en 3 a 5 días hábiles."
    redirect_to root_path
    
  else
    flash[:alert] = "Hubo un error con tu pago, intenta de nuevo."
    render :new, status: :unprocessable_entity
  end
end

  

private

def payment_params
  params.permit(:pay_method, :cart_id, :amount)
    params.permit(:pay_method, :account_info)
sche
end

  private

  def wompi_checkout_url(payment)
    pub_key = Rails.application.credentials.dig(:wompi, :public_key)

    "https://checkout.wompi.co/p/?public-key=#{pub_key}&amount-in-cents=#{(payment.amount * 100).to_i}&currency=COP&reference=#{payment.id}"
  end
end
