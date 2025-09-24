class PaymentMailer < ApplicationMailer
    default from: 'lvanesadelahoz@gmail.com'

    def invoice(payment)
        @payment = payment
        @user = payment.cart.user
            mail(to: @user.email, subject: 'Tu factura de compra - Ferremateriales El Maestro')
    end

end
