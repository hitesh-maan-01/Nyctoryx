import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'overall_score.dart';
import 'app_list.dart';

// Import section pages
import 'profile_page.dart';
import 'privacy_tips_page.dart';
import 'privacy_requiement_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'help_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> apps = [
    {"name": "App One", "score": 95, "logo": Icons.security},
    {"name": "App Two", "score": 55, "logo": Icons.warning},
    {"name": "App Three", "score": 80, "logo": Icons.verified_user},
    {'name': 'App 1', 'score': 70, 'logo': Icons.apps},
    {'name': 'App 2', 'score': 85, 'logo': Icons.phone_android},
    {'name': 'App 3', 'score': 70, 'logo': Icons.camera_alt},
    {'name': 'App 4', 'score': 40, 'logo': Icons.music_note},
    {'name': 'App 5', 'score': 60, 'logo': Icons.gamepad},
    {'name': 'App 6', 'score': 90, 'logo': Icons.map},
    {'name': 'App 7', 'score': 70, 'logo': Icons.message},
    {'name': 'App 8', 'score': 10, 'logo': Icons.photo_camera},
    {'name': 'App 9', 'score': 70, 'logo': Icons.access_alarm},
    {'name': 'App 10', 'score': 50, 'logo': Icons.assistant},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredApps = apps
        .where((app) =>
            app['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nyctoryx",
          style:
              TextStyle(color: Color.fromARGB(255, 70, 130, 180), fontSize: 28),
        ),
        backgroundColor: const Color.fromARGB(255, 15, 18, 28),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu,
                  color: Color.fromARGB(255, 70, 130, 180)),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 15, 18, 28)),
              child: Text('Menu',
                  style: TextStyle(
                      fontSize: 24, color: Color.fromARGB(255, 70, 130, 180))),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Privacy tips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyTipsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Privacy Requirement'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacyRequirementPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const OverallScore(),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "Search apps...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() => searchQuery = val);
              },
            ),
            const SizedBox(height: 20),
            AppList(apps: filteredApps),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    requestPermissionsOnce();
  }

  Future<void> requestPermissionsOnce() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    final contactStatus = await Permission.contacts.status;
    if (!contactStatus.isGranted) {
      await Permission.contacts.request();
    }

    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }

    final microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }

    // You can check and request other permissions similarly:
    // await Permission.location.request();
    // await Permission.microphone.request();
  }
}
