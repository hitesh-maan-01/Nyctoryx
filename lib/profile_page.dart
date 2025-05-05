import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool isEditing = false;
  String username = 'test_user';
  String email = 'test@example.com';
  String mobile = '+1234567890';
  String password = 'password123';
  ImageProvider? profileImage;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        _usernameController.text = username;
        _passwordController.text = '';
      }
    });
  }

  void _saveChanges() {
    setState(() {
      if (_usernameController.text.isNotEmpty) {
        username = _usernameController.text;
      }
      if (_passwordController.text.isNotEmpty) {
        password = _passwordController.text;
      }
      isEditing = false;
    });
  }

  Future<void> _pickImage() async {
    setState(() {
      profileImage = const AssetImage('assets/profile_placeholder.png');
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 18, 28),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 15, 18, 28),
        foregroundColor: const Color.fromARGB(255, 70, 130, 180),
        actions: [
          TextButton(
            onPressed: isEditing ? _saveChanges : _toggleEdit,
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: Color.fromARGB(255, 70, 130, 180),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(isEditing),
                children: [
                  GestureDetector(
                    onTap: isEditing ? _pickImage : null,
                    child: Hero(
                      tag: 'profileImage',
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImage ??
                            const AssetImage('assets/profile_placeholder.png'),
                        child: profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Color.fromARGB(179, 111, 155, 217),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoField("Username", username, _usernameController),
                  _buildInfoField("Email", email, null, isEditable: false),
                  _buildInfoField("Mobile", mobile, null, isEditable: false),
                  if (isEditing)
                    _buildInfoField(
                      "Password",
                      '',
                      _passwordController,
                      obscureText: true,
                    ),
                  const SizedBox(height: 10),
                  if (!isEditing) ...[
                    _buildSectionTitle("Security Settings"),
                    _buildOptionTile(Icons.lock, "Change Password", () {
                      _showSnackbar("Change Password");
                    }),
                    _buildOptionTile(
                      Icons.fingerprint,
                      "Two-Factor Authentication",
                      () {
                        _showSnackbar("2FA Toggled");
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Account Activity"),
                    _buildOptionTile(Icons.login, "Login History", () {
                      _showSnackbar("Login History");
                    }),
                    _buildOptionTile(Icons.location_on, "Recent Devices", () {
                      _showSnackbar("Recent Devices");
                    }),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    String value,
    TextEditingController? controller, {
    bool isEditable = true,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 70, 130, 180),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        isEditing && isEditable
            ? TextField(
                controller: controller,
                obscureText: obscureText,
                style: const TextStyle(color: Color.fromARGB(255, 15, 18, 28)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 186, 202, 222),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 186, 202, 222),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  value,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 15, 18, 28)),
                ),
              ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 15, 18, 28)),
        title: Text(
          title,
          style: const TextStyle(color: Color.fromARGB(255, 15, 18, 28)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color.fromARGB(255, 15, 18, 28),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: const Color.fromARGB(255, 186, 202, 222),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 70, 130, 180),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
