import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_apps/device_apps.dart';
import 'overall_score.dart';
import 'profile_page.dart';
import 'privacy_tips_page.dart';
import 'privacy_requiement_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'app_detail_page.dart';
import 'notification_page.dart';
import 'permission_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  List<Application> installedApps = [];
  List<Application> riskyApps = [];
  List<Application> secureApps = [];
  String searchQuery = "";
  double _listOpacity = 1.0;

  final Map<String, int> permissionUsage = {
    'Location': 4,
    'Camera': 3,
    'Microphone': 2,
    'Media': 3,
    'Contacts': 2,
    'Phone': 1,
  };

  @override
  void initState() {
    super.initState();
    loadInstalledApps();
    requestPermissionsOnce();
  }

  Future<void> loadInstalledApps({bool showSnackBar = false}) async {
    setState(() => _listOpacity = 0.0);
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
        riskyApps = risky;
        secureApps = secure;
      });

      Future.delayed(const Duration(milliseconds: 100),
          () => setState(() => _listOpacity = 1.0));

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("App list refreshed!")),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = installedApps
        .where((app) =>
            app.appName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Nyctoryx",
            style: TextStyle(color: Color(0xFF4682B4), fontSize: 28)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF4682B4)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text("Menu",
                  style: TextStyle(color: Color(0xFF4682B4), fontSize: 24)),
            ),
            _buildDrawerTile("Profile", const ProfileScreen()),
            _buildDrawerTile("Privacy Tips", PrivacyTipsPage()),
            _buildDrawerTile(
                "Privacy Requirement", const PrivacyRequirementPage()),
            _buildDrawerTile("Settings", const SettingsPage()),
            _buildDrawerTile("About", const AboutPage()),
            _buildDrawerTile("Help", const HelpPage()),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OverallScore(secureApps: secureApps, riskyApps: riskyApps),
                const SizedBox(height: 16),

                /// Apps at Risk
                Card(
                  color: Colors.red[50],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Apps at Risk",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...riskyApps.take(4).map((app) {
                          final index = riskyApps.indexOf(app);
                          final score = (45 + index * 13) % 100;
                          return ListTile(
                            leading: app is ApplicationWithIcon
                                ? Hero(
                                    tag: app.packageName,
                                    child: Image.memory(app.icon,
                                        width: 40, height: 40),
                                  )
                                : const Icon(Icons.warning),
                            title: Text(app.appName),
                            subtitle:
                                Text("Privacy Score: $score%", maxLines: 1),
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
                          );
                        }),
                        if (riskyApps.length > 4)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              child: const Text("View All"),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => ListView(
                                    children: riskyApps.map((app) {
                                      final score =
                                          40 + riskyApps.indexOf(app) * 7 % 50;
                                      return ListTile(
                                        leading: app is ApplicationWithIcon
                                            ? Image.memory(app.icon,
                                                width: 40, height: 40)
                                            : const Icon(Icons.apps),
                                        title: Text(app.appName),
                                        subtitle:
                                            Text("Privacy Score: $score%"),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AppDetailPage(
                                                app: app,
                                                privacyScore: score,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// Permission Overview
                Card(
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Permission Overview",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...permissionUsage.entries.map((entry) {
                          return PermissionTile(
                            permissionName: entry.key,
                            appCount: entry.value,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _selectedIndex == 1
              ? RefreshIndicator(
                  onRefresh: () => loadInstalledApps(showSnackBar: true),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search apps...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _listOpacity,
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: filteredApps.map((app) {
                            final index = filteredApps.indexOf(app);
                            final score = 50 + (index * 11) % 50;
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: app is ApplicationWithIcon
                                    ? Hero(
                                        tag: app.packageName,
                                        child: Image.memory(app.icon,
                                            width: 40, height: 40),
                                      )
                                    : const Icon(Icons.apps),
                                title: Text(app.appName),
                                subtitle: Text("Privacy Score: $score%"),
                                trailing: const Icon(Icons.arrow_forward_ios),
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
                )
              : _selectedIndex == 2
                  ? const Center(child: Text("Kill Switch Coming Soon..."))
                  : const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4682B4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: "Apps"),
          BottomNavigationBarItem(
              icon: Icon(Icons.power_settings_new), label: "Kill"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }

  ListTile _buildDrawerTile(String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Future<void> requestPermissionsOnce() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.contacts,
      Permission.location,
      Permission.microphone,
      Permission.phone,
    ];
    for (var permission in permissions) {
      if (!await permission.isGranted) {
        await permission.request();
      }
    }
  }
}
