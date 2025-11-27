import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ferremateriales/core/config/api_config.dart';

class PaymentService {

  Future<Map<String, dynamic>> createPayment({
    required int cartId,
    required int amount,
    //required int userId,
  }) async {

final url = Uri.parse(ApiConfig.paymentsUrl);

    print("=== PAYMENT SERVICE DEBUG ===");
    print("URL: $url");
    print("Cart ID: $cartId");
    print("Amount: $amount");
    
    final body = jsonEncode({
        "cart_id": cartId,
        "amount": amount,
        "currency": "COP",
        "pay_method": "card",
      //  "user_id": userId,
        "redirect_url": "${ApiConfig.baseUrl}/mobile_redirect"
    });
    
    print("Request body: $body");

    try {
      print("Enviando petición HTTP...");
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: body,
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      print("Response headers: ${response.headers}");

      if (response.statusCode != 200) {
        print("ERROR: Status code ${response.statusCode}");
        throw Exception("Error creando pago: ${response.body}");
      }

      final result = jsonDecode(response.body);
      print("Pago creado exitosamente: $result");
      return result;
    } catch (e) {
      print("EXCEPCIÓN en createPayment: $e");
      rethrow;
    }
  }
}
