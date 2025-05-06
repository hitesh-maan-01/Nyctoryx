import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color textColor = const Color.fromARGB(255, 70, 130, 180);
  final Color backgroundColor = const Color.fromARGB(255, 15, 18, 28);

  bool _camera = false;
  bool _location = false;
  bool _microphone = false;
  bool _storage = false;
  bool _contacts = false;

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 186, 202, 222),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(icon, color: textColor),
          title: Text(title, style: TextStyle(color: textColor)),
          onTap: () => _navigateWithAnimation(context, screen),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 186, 202, 222),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(icon, color: textColor),
          title: Text(title, style: TextStyle(color: textColor)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: textColor,
          ),
          onTap: () => onChanged(!value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Settings', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingTile(
            'Check for Updates',
            Icons.system_update,
            const UpdateScreen(),
          ),
          _buildSettingTile(
            'Security Features',
            Icons.security,
            const SecurityScreen(),
          ),
          _buildSettingTile(
              'Run Security Scan', Icons.shield, const ScanScreen()),
          _buildSettingTile(
            'User Agreement',
            Icons.description,
            const AgreementScreen(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 186, 202, 222),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ExpansionTile(
                leading: Icon(Icons.privacy_tip, color: textColor),
                title: Text(
                  'Permission Options',
                  style: TextStyle(color: textColor),
                ),
                children: [
                  _buildSwitchTile(
                    'Camera',
                    Icons.camera_alt,
                    _camera,
                    (val) => setState(() => _camera = val),
                  ),
                  _buildSwitchTile(
                    'Location',
                    Icons.location_on,
                    _location,
                    (val) => setState(() => _location = val),
                  ),
                  _buildSwitchTile(
                    'Microphone',
                    Icons.mic,
                    _microphone,
                    (val) => setState(() => _microphone = val),
                  ),
                  _buildSwitchTile(
                    'Storage',
                    Icons.sd_storage,
                    _storage,
                    (val) => setState(() => _storage = val),
                  ),
                  _buildSwitchTile(
                    'Contacts',
                    Icons.contacts,
                    _contacts,
                    (val) => setState(() => _contacts = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Below are the placeholder screens for navigation

class UpdateScreen extends StatelessWidget {
  final Color bg = const Color.fromARGB(255, 15, 18, 28);
  final Color fg = const Color.fromARGB(255, 70, 130, 180);

  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Check for Updates', style: TextStyle(color: fg)),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: fg),
      ),
      body: Center(
        child: Text('Your app is up to date.', style: TextStyle(color: fg)),
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  final Color bg = const Color.fromARGB(255, 15, 18, 28);
  final Color fg = const Color.fromARGB(255, 70, 130, 180);

  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Security Features', style: TextStyle(color: fg)),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: fg),
      ),
      body: Center(
        child: Text(
          'Manage your security features.',
          style: TextStyle(color: fg),
        ),
      ),
    );
  }
}

class ScanScreen extends StatelessWidget {
  final Color bg = const Color.fromARGB(255, 15, 18, 28);
  final Color fg = const Color.fromARGB(255, 70, 130, 180);

  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Security Scan', style: TextStyle(color: fg)),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: fg),
      ),
      body: Center(
        child: Text(
          'Scanning... No threats found.',
          style: TextStyle(color: fg),
        ),
      ),
    );
  }
}

class AgreementScreen extends StatelessWidget {
  final Color bg = const Color.fromARGB(255, 15, 18, 28);
  final Color fg = const Color.fromARGB(255, 70, 130, 180);

  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('User Agreement', style: TextStyle(color: fg)),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: fg),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'This is the user agreement. Please read and accept the terms.',
          style: TextStyle(color: fg),
        ),
      ),
    );
  }
}
