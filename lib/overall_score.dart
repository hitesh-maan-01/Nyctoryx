import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'app_detail_page.dart';

class OverallScore extends StatefulWidget {
  final List<Application> secureApps;
  final List<Application> riskyApps;

  const OverallScore({
    super.key,
    required this.secureApps,
    required this.riskyApps,
  });

  @override
  State<OverallScore> createState() => _OverallScoreState();
}

class _OverallScoreState extends State<OverallScore> {
  @override
  Widget build(BuildContext context) {
    int secureCount = widget.secureApps.length;
    int riskyCount = widget.riskyApps.length;
    int total = secureCount + riskyCount;

    double securePercent = total > 0 ? (secureCount / total) * 100 : 0;
    double riskyPercent = total > 0 ? (riskyCount / total) * 100 : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Overall Privacy Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: securePercent,
                      title: '${securePercent.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: riskyPercent,
                      title: '${riskyPercent.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.secureApps.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppListScreen(
                            title: 'Secure Apps',
                            apps: widget.secureApps,
                          ),
                        ),
                      );
                    }
                  },
                  child: Chip(
                    avatar: const Icon(Icons.check_circle, color: Colors.green),
                    label: Text('Secure: $secureCount'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.riskyApps.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppListScreen(
                            title: 'Risky Apps',
                            apps: widget.riskyApps,
                          ),
                        ),
                      );
                    }
                  },
                  child: Chip(
                    avatar: const Icon(Icons.warning, color: Colors.red),
                    label: Text('Risky: $riskyCount'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add rescan logic here
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Rescan All Apps"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 241, 241, 245)),
            ),
          ],
        ),
      ),
    );
  }
}

class AppListScreen extends StatelessWidget {
  final String title;
  final List<Application> apps;

  const AppListScreen({
    super.key,
    required this.title,
    required this.apps,
  });

  int _mockPrivacyScore(Application app) {
    return app.packageName.length % 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          final score = _mockPrivacyScore(app);

          return ListTile(
            leading: app is ApplicationWithIcon
                ? Image.memory(
                    app.icon,
                    width: 40,
                    height: 40,
                  )
                : const Icon(Icons.apps),
            title: Text(app.appName),
            subtitle: Text('Privacy Score: $score%'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppDetailPage(
                    app: app,
                    privacyScore: score,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
