import 'package:flutter/material.dart';
import 'permission_screen.dart'; // Create individual screens if needed

class PermissionTile extends StatelessWidget {
  final String permissionName;
  final int appCount;

  const PermissionTile({
    super.key,
    required this.permissionName,
    required this.appCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PermissionScreen(permissionName: permissionName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueGrey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(permissionName, style: const TextStyle(fontSize: 16)),
            Text("$appCount apps", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
