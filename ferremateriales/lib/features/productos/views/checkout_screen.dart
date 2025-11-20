import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final String checkoutUrl;

  const CheckoutScreen({required this.checkoutUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pagar con Wompi")),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(checkoutUrl)),
      ),
    );
  }
}
