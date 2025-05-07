import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class AppDetailPage extends StatelessWidget {
  final Application app;
  final int privacyScore;

  const AppDetailPage({
    super.key,
    required this.app,
    required this.privacyScore,
  });

  Future<Map<String, String>> _getAppStatus(Application app) async {
    return {
      'Version': app.versionName ?? 'Unknown',
      'Size': '${(app.apkFilePath.length / 1024).toStringAsFixed(2)} KB',
      'Background Mode': app.enabled ? 'Enabled' : 'Disabled',
      'Auto Updates': 'Unknown', // Could be enhanced using Play Store APIs
    };
  }

  Future<Map<String, bool>> _checkPermissions() async {
    final Map<String, Permission> permissions = {
      "Camera": Permission.camera,
      "Storage": Permission.storage,
      "Media": Permission.mediaLibrary,
      "Location": Permission.location,
      "Contacts": Permission.contacts,
      "Microphone": Permission.microphone,
    };

    Map<String, bool> results = {};
    for (var entry in permissions.entries) {
      results[entry.key] = await entry.value.isGranted;
    }

    return results;
  }

  // Open the specific app's settings page
  Future<void> _openAppSettings(String packageName) async {
    if (Platform.isAndroid) {
      // For Android, use device_apps to open the app settings
      DeviceApps.openAppSettings(packageName);
    } else if (Platform.isIOS) {
      // For iOS, use url_launcher to open the app settings page
      final url = Uri.parse('app-settings:');
      if (await canLaunch(url.toString())) {
        await launch(url.toString());
      } else {
        // If it can't launch, fall back to app settings
        openAppSettings();
      }
    }
  }

  // Uninstall the app (Android)
  Future<void> _uninstallApp(String packageName) async {
    final url = 'package:$packageName';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  // Example recommendations based on privacy score
  String _getRecommendations(int privacyScore) {
    if (privacyScore >= 80) {
      return "Your app's privacy score is great! No action needed.";
    } else if (privacyScore >= 50) {
      return "Consider reviewing the app's permissions and security features.";
    } else {
      return "Your app has several risks. We recommend reviewing its permissions and performing a security scan.";
    }
  }

  // Example background activity data
  Map<String, String> _getBackgroundActivity() {
    return {
      'Location': 'Enabled',
      'Network Activity': 'Low',
      'Battery Usage': 'Moderate',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Insights"),
        backgroundColor: const Color.fromARGB(255, 241, 242, 244),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([_getAppStatus(app), _checkPermissions()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appStatus = snapshot.data![0] as Map<String, String>;
          final permissions = snapshot.data![1] as Map<String, bool>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App icon and name
                Row(
                  children: [
                    if (app is ApplicationWithIcon)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          (app as ApplicationWithIcon).icon,
                          width: 64,
                          height: 64,
                        ),
                      )
                    else
                      const Icon(Icons.apps, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        app.appName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Privacy Score
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Privacy Score",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        PieChart(
                          dataMap: {
                            "Safe": privacyScore.toDouble(),
                            "Risk": (100 - privacyScore).toDouble(),
                          },
                          colorList: const [Colors.green, Colors.redAccent],
                          chartType: ChartType.ring,
                          chartRadius: 120,
                          ringStrokeWidth: 18,
                          centerText: "$privacyScore%",
                          legendOptions: const LegendOptions(
                            showLegends: false,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Permissions
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Permissions",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ...permissions.entries.map((entry) {
                          return ListTile(
                            leading: Icon(
                              entry.value
                                  ? Icons.check_circle
                                  : Icons.cancel_outlined,
                              color: entry.value
                                  ? (["Camera", "Location", "Microphone"]
                                          .contains(entry.key)
                                      ? Colors.orange
                                      : Colors.green)
                                  : Colors.red,
                            ),
                            title: Text(entry.key),
                            subtitle: Text(entry.value
                                ? "Permission Granted"
                                : "Permission Denied"),
                            trailing: IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                // Open the specific app settings page
                                _openAppSettings(app.packageName);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // App Status
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "App Status",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),

                        // App Version
                        ListTile(
                          leading: const Icon(Icons.system_update),
                          title: const Text("Version"),
                          subtitle: Text(app.versionName ?? "Unknown"),
                        ),

                        // App Size
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: const Text("Size"),
                          subtitle: Text(() {
                            if (app is ApplicationWithIcon) {
                              final file = File(app.apkFilePath);
                              if (file.existsSync()) {
                                final sizeInKB = file.lengthSync() / 1024;
                                return "${sizeInKB.toStringAsFixed(2)} KB";
                              }
                            }
                            return "Unavailable";
                          }()),
                        ),

                        // Auto Updates (via Play Store)
                        ListTile(
                          leading: const Icon(Icons.update),
                          title: const Text("Auto Updates"),
                          subtitle: const Text("Manage via Play Store"),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final url = Uri.parse(
                                  'https://play.google.com/store/apps/details?id=${app.packageName}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: const Text("Open"),
                          ),
                        ),

                        // Background Mode
                        ListTile(
                          leading: const Icon(Icons.android),
                          title: const Text("Background Mode"),
                          subtitle: Text(app.enabled ? 'Enabled' : 'Disabled'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Background Activity
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Background Activity",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12),
                        ListTile(
                          leading: Icon(Icons.location_on_outlined),
                          title: Text("Location"),
                          subtitle: Text("May use location in background mode"),
                        ),
                        ListTile(
                          leading: Icon(Icons.network_check),
                          title: Text("Network Activity"),
                          subtitle: Text("Might access internet in background"),
                        ),
                        ListTile(
                          leading: Icon(Icons.battery_alert_outlined),
                          title: Text("Battery Usage"),
                          subtitle:
                              Text("No heavy battery usage detected recently"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Recommendations
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recommendations",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12),
                        Text("• Revoke unused permissions."),
                        Text("• Disable background data usage if not needed."),
                        Text("• Uninstall apps with low privacy score."),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Uninstall App
                Center(
                  child: ElevatedButton(
                    onPressed: () => DeviceApps.uninstallApp(app.packageName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    child: const Text(
                      "Uninstall App",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
