import 'package:flutter/material.dart';

class PrivacyTipsPage extends StatelessWidget {
  final List<String> tips = [
    'Review app permissions regularly.',
    'Disable unnecessary background data usage.',
    'Use apps from trusted developers only.',
    'Limit access to sensitive information.',
    'Use VPNs for secure browsing.'
  ];

  PrivacyTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Tips')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: Text(tips[index]),
        ),
      ),
    );
  }
}
