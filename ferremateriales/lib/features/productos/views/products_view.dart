import 'package:flutter/material.dart';

import '../widgets/producto_card.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: BalanceWidget()));
  }
}
