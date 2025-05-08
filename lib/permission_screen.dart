import 'package:flutter/material.dart';

class PermissionScreen extends StatelessWidget {
  final String permissionName;

  const PermissionScreen({super.key, required this.permissionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$permissionName Permission'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF4682B4)),
        titleTextStyle: const TextStyle(color: Color(0xFF4682B4), fontSize: 20),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apps Using $permissionName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Placeholder count
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.privacy_tip,
                          color: Color(0xFF4682B4)),
                      title: Text('$permissionName App ${index + 1}'),
                      subtitle: Text('Risk Level: ${[
                        "Low",
                        "Medium",
                        "High"
                      ][index % 3]}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Add navigation to detail if needed
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
