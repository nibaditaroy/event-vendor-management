import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../organizer/discover_screen.dart';
import 'register_screen.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _keepSigned = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Placeholder
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_seat, size: 28),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EVENTVENDOR',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
                      ),
                      Text(
                        'MANAGEMENT',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, letterSpacing: 1.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 60),
              
              // Welcome Text
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1a365d)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your credentials to manage your curation.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Role Toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => authProvider.setRole('organizer'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: authProvider.userRole == 'organizer' ? primaryColor : Colors.grey.shade300,
                            width: authProvider.userRole == 'organizer' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: authProvider.userRole == 'organizer' ? primaryColor.withOpacity(0.05) : Colors.white,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person, color: authProvider.userRole == 'organizer' ? primaryColor : Colors.grey),
                            const SizedBox(height: 8),
                            Text('Organizer', style: TextStyle(fontWeight: FontWeight.bold, color: authProvider.userRole == 'organizer' ? primaryColor : Colors.grey)),
                            Text('BOOK & MANAGE', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => authProvider.setRole('vendor'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: authProvider.userRole == 'vendor' ? primaryColor : Colors.grey.shade300,
                            width: authProvider.userRole == 'vendor' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: authProvider.userRole == 'vendor' ? primaryColor.withOpacity(0.05) : Colors.white,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.storefront, color: authProvider.userRole == 'vendor' ? primaryColor : Colors.grey),
                            const SizedBox(height: 8),
                            Text('Vendor', style: TextStyle(fontWeight: FontWeight.bold, color: authProvider.userRole == 'vendor' ? primaryColor : Colors.grey)),
                            Text('SHOWCASE WORK', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Email Field
              const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'curator@executive.com',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Password Field
              const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Keep Signed In
              Row(
                children: [
                  Checkbox(
                    value: _keepSigned,
                    onChanged: (val) => setState(() => _keepSigned = val ?? false),
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Text('Keep me signed in for 30 days', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 32),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter email and password')),
                    );
                    return;
                  }

                  final success = await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                  );

                  if (success && mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed. Please check your credentials.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              // Create Account
              const Center(
                child: Text('NEW TO THE PLATFORM?', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
