class PaymentsController < ApplicationController

  protect_from_forgery except: :webhook
  def new
    @payment = Payment.create!(
       cart: current_cart,
      amount: current_cart.total,
      pay_method: nil,
      status: :pending
    )
  end

  def status
  end

  def checkout
  end

  def create
    @payment = Payment.find(params[:payment_id])
    @payment.update(pay_method: params[:pay_method])
      redirect_to wompi_checkout_url(@payment)

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

  private

  def wompi_checkout_url(payment)
    pub_key = Rails.application.credentials.dig(:wompi, :public_key)

    "https://checkout.wompi.co/p/?public-key=#{pub_key}&amount-in-cents=#{(payment.amount * 100).to_i}&currency=COP&reference=#{payment.id}"
  end
end
