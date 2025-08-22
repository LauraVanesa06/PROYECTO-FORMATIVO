
import 'package:flutter/material.dart';

class PaymentView extends StatefulWidget {
  final double total; // 👈 Recibimos el total del carrito

  const PaymentView({super.key, required this.total});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes manejar el proceso real de pago o simularlo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pago de \$${widget.total} realizado con éxito 🎉"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // volvemos al carrito después del pago
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Método de Pago"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Total a pagar: \$${widget.total}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Número de tarjeta
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: "Número de Tarjeta",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 16) {
                    return "Ingrese un número de tarjeta válido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Fecha de vencimiento
              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: "Fecha de Expiración (MM/AA)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains("/")) {
                    return "Ingrese una fecha válida";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // CVV
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: "CVV",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return "Ingrese un CVV válido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Dirección
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Dirección de Envío",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese una dirección válida";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botón pagar
              ElevatedButton.icon(
                onPressed: _confirmPayment,
                icon: const Icon(Icons.check_circle),
                label: const Text("Confirmar Pago"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
