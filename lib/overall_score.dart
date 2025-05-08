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
    double securePercent = total > 0 ? (secureCount / total) * 90 : 0;
    double riskyPercent = total > 0 ? (riskyCount / total) * 90 : 0;

    // Compute mock overall score
    double overallScore = securePercent;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppListScreen(
                          title: 'Privacy Report',
                          apps: widget.secureApps + widget.riskyApps,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Overall Privacy Score',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      sections: _buildPieSections(overallScore),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeInOutCubic,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${overallScore.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Secure'),
                    ],
                  ),
                ],
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
                // Add real rescan logic here
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Rescan All Apps"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 241, 241, 245),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(double score) {
    final List<PieChartSectionData> sections = [];

    if (score >= 80) {
      sections.add(_createSection(score, Colors.green));
      sections.add(_createSection(100 - score, Colors.grey[300]!));
    } else if (score >= 60) {
      sections.add(_createSection(score, Colors.amber));
      sections.add(_createSection(100 - score, Colors.grey[300]!));
    } else if (score >= 40) {
      sections.add(_createSection(score, Colors.orange));
      sections.add(_createSection(100 - score, Colors.grey[300]!));
    } else {
      sections.add(_createSection(score, Colors.red));
      sections.add(_createSection(100 - score, Colors.grey[300]!));
    }

    return sections;
  }

  PieChartSectionData _createSection(double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: 50,
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
    final length = app.packageName.length;
    if (length % 4 == 0) return 85;
    if (length % 4 == 1) return 65;
    if (length % 4 == 2) return 45;
    return 25;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 226, 227, 233),
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
