class PaymentMailer < ApplicationMailer
    default from: 'ferreteriasoporte3@gmail.com'

    def invoice
        @payment = params[:payment]
        @user = @payment.cart.user
        mail(to: @user.email, subject: 'Tu factura de compra - Ferremateriales El Maestro')
       
    end

end
