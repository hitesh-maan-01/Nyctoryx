import 'package:flutter/material.dart';

class PrivacyRequirementPage extends StatelessWidget {
  const PrivacyRequirementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Requirements')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'To ensure privacy and security, Nyctoryx recommends the following requirements for apps:\n\n'
          '- Clear privacy policy\n'
          '- Explicit permission requests\n'
          '- Data encryption\n'
          '- Limited third-party data sharing\n'
          '- Option to delete user data',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
