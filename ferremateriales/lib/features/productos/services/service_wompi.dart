import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  final String baseUrl = "https://interisland-uninferrably-leonie.ngrok-free.dev"; 


  Future<Map<String, dynamic>> createPayment({
    required int cartId,
    required int amount,
    required int userId,
  }) async {
    final url = Uri.parse("$baseUrl/api/payments/create_Checkout");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cart_id": cartId,
        "amount": amount,
        "currency": "COP",
        "pay_method": "card",
        "user_id": userId
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error creando pago: ${response.body}");
    }

    return jsonDecode(response.body);
  }
}
