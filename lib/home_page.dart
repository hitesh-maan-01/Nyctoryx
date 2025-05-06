import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_apps/device_apps.dart'
    show Application, ApplicationWithIcon, DeviceApps;

import 'overall_score.dart';

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
  List<Application> installedApps = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadInstalledApps();
    requestPermissionsOnce();
  }

  Future<void> loadInstalledApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );
    setState(() {
      installedApps = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = installedApps.where((app) {
      return app.appName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

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
                Navigator.pop(context);
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
                      builder: (context) => const PrivacyRequirementPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return ListTile(
                    leading: app is ApplicationWithIcon
                        ? Image.memory(app.icon, width: 40, height: 40)
                        : const Icon(Icons.apps),
                    title: Text(app.appName),
                    subtitle: Text(app.packageName),
                    onTap: () {
                      // Optionally handle tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
  }
}
