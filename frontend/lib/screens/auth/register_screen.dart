import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'organizer';
  int? _selectedCategoryId;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1a365d)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join the premier event vendor portal.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Role Selection
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ORGANIZER')),
                      selected: _selectedRole == 'organizer',
                      onSelected: (val) => setState(() => _selectedRole = 'organizer'),
                      selectedColor: primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: _selectedRole == 'organizer' ? primaryColor : Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('VENDOR')),
                      selected: _selectedRole == 'vendor',
                      onSelected: (val) => setState(() => _selectedRole = 'vendor'),
                      selectedColor: primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: _selectedRole == 'vendor' ? primaryColor : Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (_selectedRole == 'vendor') ...[
                const Text('BUSINESS CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Consumer<CategoryProvider>(
                  builder: (context, catProvider, _) {
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      hint: const Text('Select a category'),
                      items: catProvider.categories.map((c) => DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name']),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              _buildField('FULL NAME', 'John Doe', _nameController),
              const SizedBox(height: 20),
              _buildField('EMAIL ADDRESS', 'john@example.com', _emailController),
              const SizedBox(height: 20),
              _buildField('PHONE NUMBER', '01XXXXXXXXX', _phoneController, prefix: '+88 '),
              const SizedBox(height: 20),
              _buildField('PASSWORD', '••••••••', _passwordController, obscure: _obscurePassword, isPassword: true),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                    return;
                  }

                  final success = await authProvider.register(
                    _nameController.text,
                    _emailController.text,
                    '+88${_phoneController.text}',
                    _passwordController.text,
                    _selectedRole,
                    categoryId: _selectedCategoryId,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.')));
                    Navigator.pop(context);
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed.')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {bool obscure = false, bool isPassword = false, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix != null ? Container(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(prefix, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ) : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) : null,
          ),
        ),
      ],
    );
  }
}
