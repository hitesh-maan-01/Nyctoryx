import 'package:flutter/material.dart';

class AppList extends StatelessWidget {
  final List<Map<String, dynamic>> apps;

  const AppList({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    return Column(children: apps.map((app) => AppCard(app: app)).toList());
  }
}

class AppCard extends StatelessWidget {
  final Map<String, dynamic> app;

  const AppCard({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(app['logo'], size: 40),
        title: Text(app['name']),
        subtitle: Text("Privacy Score: ${app['score']} / 100"),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(_createRoute());
          },
          child: const Text("View"),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AppDetailPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));
        return SlideTransition(
          position: animation.drive(offset),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

// ------------------------------------
// Detailed App Page and Components
// ------------------------------------

class AppDetailPage extends StatelessWidget {
  const AppDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Privacy Details')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            AppHeader(),
            SizedBox(height: 16),
            PrivacyAlertsSection(),
            SizedBox(height: 16),
            PermissionsSection(),
            SizedBox(height: 16),
            BackgroundActivitySection(),
            SizedBox(height: 16),
            PrivacyScoreSection(),
            SizedBox(height: 16),
            AppStatusSection(),
            SizedBox(height: 16),
            RecommendationsSection(),
          ],
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.security, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Social Connect',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Privacy-focused messenger app',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // handle manage permissions
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12)),
                  child:
                      const Text('Permissions', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () {
                    // handle uninstall
                  },
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child:
                      const Text('Uninstall', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyAlertsSection extends StatefulWidget {
  const PrivacyAlertsSection({super.key});

  @override
  State<PrivacyAlertsSection> createState() => _PrivacyAlertsSectionState();
}

class _PrivacyAlertsSectionState extends State<PrivacyAlertsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          AlertCard(
              color: Color.fromARGB(255, 178, 34, 56),
              title: 'Excessive Background Location Access',
              date: 'Today',
              buttonText: 'Restrict Access'),
          AlertCard(
              color: Color.fromARGB(255, 144, 131, 16),
              title: 'Contacts Permission Usage',
              date: 'Yesterday',
              buttonText: 'Review Access'),
          AlertCard(
              color: Color.fromARGB(255, 30, 98, 147),
              title: 'Privacy Policy Updated',
              date: '3 days ago',
              buttonText: 'View Changes'),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Color? color;
  final String title;
  final String date;
  final String buttonText;

  const AlertCard(
      {super.key,
      required this.color,
      required this.title,
      required this.date,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: ListTile(
        title: Text(title),
        subtitle: Text(date),
        trailing: ElevatedButton(onPressed: () {}, child: Text(buttonText)),
      ),
    );
  }
}

class PermissionsSection extends StatelessWidget {
  const PermissionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Permissions & Data Access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        PermissionSwitch(title: 'Location', value: true),
        PermissionSwitch(title: 'Camera', value: true),
        PermissionSwitch(title: 'Microphone', value: false),
        PermissionSwitch(title: 'Contacts', value: true),
        PermissionSwitch(title: 'Photos and Videos', value: true),
      ],
    );
  }
}

class PermissionSwitch extends StatefulWidget {
  final String title;
  final bool value;
  const PermissionSwitch({super.key, required this.title, required this.value});

  @override
  State<PermissionSwitch> createState() => _PermissionSwitchState();
}

class _PermissionSwitchState extends State<PermissionSwitch> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      value: _enabled,
      onChanged: (val) => setState(() => _enabled = val),
    );
  }
}

class BackgroundActivitySection extends StatelessWidget {
  const BackgroundActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Background Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(
            title: Text('Location Access'),
            subtitle: Text('47 times in last 24h')),
        ListTile(
            title: Text('Network Activity'),
            subtitle: Text('28 times in last 24h')),
        ListTile(
            title: Text('Battery Usage'), subtitle: Text('4% in last 24h')),
      ],
    );
  }
}

class PrivacyScoreSection extends StatelessWidget {
  const PrivacyScoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 62),
      duration: const Duration(seconds: 1),
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy Score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigo,
                  child: Text(value.toInt().toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text(
                        'Medium Privacy Risk – This app has some concerning privacy practices.')),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AppStatusSection extends StatelessWidget {
  const AppStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          ListTile(title: Text('Version'), subtitle: Text('3.2.1')),
          ListTile(title: Text('Background Mode'), subtitle: Text('Enabled')),
          ListTile(title: Text('Auto Updates'), subtitle: Text('Enabled')),
          ListTile(title: Text('Data Collection'), subtitle: Text('High')),
        ],
      ),
    );
  }
}

class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommendations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: () {}, child: const Text('Limit Background Location')),
        ElevatedButton(
            onPressed: () {}, child: const Text('Review Data Collection')),
        OutlinedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PlaceholderPage()));
          },
          child: const Text('View Alternative Apps'),
        ),
      ],
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alternative Apps')),
      body: const Center(
          child: Text('Here you can suggest privacy-friendly alternatives.')),
    );
  }
}
