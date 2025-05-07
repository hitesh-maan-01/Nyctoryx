import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_apps/device_apps.dart'
    show Application, ApplicationWithIcon, DeviceApps;
import 'overall_score.dart';
import 'profile_page.dart';
import 'privacy_tips_page.dart';
import 'privacy_requiement_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'app_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Application> installedApps = [];
  String searchQuery = "";
  List<Application> secureApps = [];
  List<Application> riskyApps = [];
  double _listOpacity = 1.0; // Controls the fade-in effect

  @override
  void initState() {
    super.initState();
    loadInstalledApps();
    requestPermissionsOnce();
  }

  // Load installed apps
  Future<void> loadInstalledApps({bool showSnackBar = false}) async {
    // Start fade-out
    setState(() => _listOpacity = 0.0);

    // Delay a bit so the fade-out is visible
    await Future.delayed(const Duration(milliseconds: 200));

    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );

    List<Application> secure = [];
    List<Application> risky = [];

    for (var app in apps) {
      if (app.appName.toLowerCase().contains('secure')) {
        secure.add(app);
      } else {
        risky.add(app);
      }
    }

    if (mounted) {
      setState(() {
        installedApps = apps;
        secureApps = secure;
        riskyApps = risky;
      });

      // Trigger fade-in
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _listOpacity = 1.0);
        }
      });

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App list refreshed!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            _buildDrawerTile('Profile', const ProfileScreen()),
            _buildDrawerTile('Privacy tips', PrivacyTipsPage()),
            _buildDrawerTile(
                'Privacy Requirement', const PrivacyRequirementPage()),
            _buildDrawerTile('Settings', const SettingsPage()),
            _buildDrawerTile('About', const AboutPage()),
            _buildDrawerTile('Help', const HelpPage()),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => loadInstalledApps(showSnackBar: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pass secure and risky apps to OverallScore
            OverallScore(
              secureApps: secureApps,
              riskyApps: riskyApps,
            ),
            const SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
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
            ),
            const SizedBox(height: 20),
            // Apps list with fade-in animation
            AnimatedOpacity(
              opacity: _listOpacity,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: filteredApps.map((app) {
                  final index = filteredApps.indexOf(app);
                  final score = (50 + (index * 17) % 50);

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: app is ApplicationWithIcon
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  Image.memory(app.icon, width: 48, height: 48),
                            )
                          : const Icon(Icons.apps, size: 40),
                      title: Text(app.appName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.packageName,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("Privacy Score: $score%",
                              style: TextStyle(
                                  color: score > 70
                                      ? Colors.green
                                      : Colors.orange)),
                          const SizedBox(height: 2),
                          const Text("Last used: Recently",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppDetailPage(
                              app: app,
                              privacyScore: score,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerTile(String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
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
