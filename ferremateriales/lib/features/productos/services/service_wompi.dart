import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  // URL de ngrok para producción
  final String baseUrl = "https://interisland-uninferrably-leonie.ngrok-free.dev";

  Future<Map<String, dynamic>> createPayment({
    required int cartId,
    required int amount,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/payments/create_checkout");

    print('=== PaymentService.createPayment ===');
    print('URL: $url');
    print('Cart ID: $cartId');
    print('Amount: $amount');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cart_id": cartId,
          "amount": amount,
          "currency": "COP",
          "pay_method": "card",
          "redirect_url": "$baseUrl/api/v1/payments/success"
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception("Error creando pago (${response.statusCode}): ${response.body}");
      }

      final data = jsonDecode(response.body);
      print('Checkout URL: ${data["checkout_url"]}');
      return data;
    } catch (e) {
      print('ERROR en createPayment: $e');
      rethrow;
    }
  }
}
