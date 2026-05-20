import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../common/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        _userData = jsonDecode(userJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('PROFILE', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (_userData?['profile_image'] != null && _userData!['profile_image'].toString().isNotEmpty)
                      ? NetworkImage(_userData!['profile_image'])
                      : null,
                    child: (_userData?['profile_image'] == null || _userData!['profile_image'].toString().isEmpty)
                      ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _updateProfileImage(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF1a365d), shape: BoxShape.circle),
                        child: _isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(_userData?['name'] ?? 'User Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_userData?['email'] ?? 'user@example.com', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1a365d).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                (_userData?['role'] ?? 'Organizer').toString().toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1a365d)),
              ),
            ),
            const SizedBox(height: 40),
            
            _buildProfileOption(Icons.person_outline, 'Personal Information', onTap: () => _showEditDetailsModal()),
            _buildProfileOption(Icons.lock_outline, 'Change Password', onTap: () => _showChangePasswordModal()),
            _buildProfileOption(Icons.notifications_none, 'Notifications', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            }),
            _buildProfileOption(Icons.security_outlined, 'Privacy & Security', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy settings are coming soon!')));
            }),
            _buildProfileOption(Icons.help_outline, 'Help & Support', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & Support is coming soon!')));
            }),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final res = await ApiService.uploadImage(image);
        final data = jsonDecode(res.body);
        if (data['success']) {
          final imageUrl = data['data']['url'];
          final success = await Provider.of<AuthProvider>(context, listen: false).updateProfile({'profile_image': imageUrl});
          if (success) {
            await _loadUserData();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated!')));
          }
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showChangePasswordModal() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CHANGE PASSWORD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildInputField('CURRENT PASSWORD', '••••••••', oldController, isPassword: true),
              const SizedBox(height: 16),
              _buildInputField('NEW PASSWORD', '••••••••', newController, isPassword: true),
              const SizedBox(height: 16),
              _buildInputField('CONFIRM NEW PASSWORD', '••••••••', confirmController, isPassword: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (newController.text != confirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
                      return;
                    }
                    if (newController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
                      return;
                    }

                    setModalState(() => isLoading = true);
                    final success = await Provider.of<AuthProvider>(context, listen: false).changePassword(
                      oldController.text,
                      newController.text,
                    );
                    setModalState(() => isLoading = false);

                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully!')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to change password. Check your current password.')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a365d),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('UPDATE PASSWORD'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDetailsModal() {
    final nameController = TextEditingController(text: _userData?['name']);
    final phoneController = TextEditingController(text: _userData?['phone']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EDIT PERSONAL INFO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInputField('FULL NAME', 'Your Name', nameController),
            const SizedBox(height: 16),
            _buildInputField('PHONE NUMBER', '01XXX-XXXXXX', phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await Provider.of<AuthProvider>(context, listen: false).updateProfile({
                    'name': nameController.text,
                    'phone': phoneController.text,
                  });
                  if (success) {
                    await _loadUserData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details updated!')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a365d),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true, fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }
}
