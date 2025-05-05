import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OverallScore extends StatefulWidget {
  const OverallScore({super.key});

  @override
  State<OverallScore> createState() => _OverallScoreState();
}

class _OverallScoreState extends State<OverallScore> {
  final int secureApps = 15;
  final int riskyApps = 5;

  @override
  Widget build(BuildContext context) {
    int total = secureApps + riskyApps;
    double securePercent = secureApps / total * 100;
    double riskyPercent = riskyApps / total * 100;

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
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green),
                  label: Text('Secure: $secureApps'),
                ),
                Chip(
                  avatar: const Icon(Icons.warning, color: Colors.red),
                  label: Text('Risky: $riskyApps'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add scan logic here
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Rescan All Apps"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
