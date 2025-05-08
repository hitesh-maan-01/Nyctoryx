import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'If you need help using Nyctoryx, please refer to our documentation or reach out to support:\n\n'
          '• Visit our help center\n'
          '• Email us at: support@nyctoryx.com\n'
          '• Check FAQs within the Settings',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
