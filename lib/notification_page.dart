import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<String> today = ['New update available', 'Privacy scan completed'];
  final List<String> yesterday = ['App permission changed'];
  final List<String> last30Days = [
    'Weekly summary available',
    'Security alert',
  ];

  final Color bgColor = const Color.fromARGB(255, 0, 0, 0);
  final Color textColor = const Color.fromARGB(255, 70, 130, 180);

   NotificationPage({super.key});

  Widget buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (e) => ListTile(
            title: Text(e, style: const TextStyle(color: Colors.white)),
            leading: Icon(Icons.notifications, color: textColor),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: bgColor,
        foregroundColor: textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildSection('Today', today),
            buildSection('Yesterday', yesterday),
            buildSection('Last 30 Days', last30Days),
          ],
        ),
      ),
    );
  }
}
