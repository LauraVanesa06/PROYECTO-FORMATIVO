import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Center(
        child: Text(l10n.notifications, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
