import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/notification_provider.dart';
import '../auth/login_screen.dart';
import 'vendor_detail_screen.dart';
import '../common/notifications_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<VendorProvider>(context, listen: false).fetchVendors();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  void _onCategorySelected(int? id) {
    setState(() => _selectedCategoryId = id);
    Provider.of<VendorProvider>(context, listen: false).fetchVendors(categoryId: id);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final vendorProvider = Provider.of<VendorProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'EVENT VENDOR PORTAL',
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final unreadCount = notificationProvider.notifications.where((n) => !n['is_read']).length;
              return IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                icon: Badge.count(
                  count: unreadCount,
                  isLabelVisible: unreadCount > 0,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.notifications_outlined, color: Colors.black),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CURATED EXCELLENCE',
              style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Discover the '),
                  TextSpan(text: 'Extraordinary', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<VendorProvider>(context, listen: false).fetchVendors(
                  categoryId: _selectedCategoryId,
                  search: value,
                );
              },
              decoration: InputDecoration(
                hintText: 'Search premier vendors...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<VendorProvider>(context, listen: false).fetchVendors(categoryId: _selectedCategoryId);
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Categories List
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryItem(Icons.apps, 'ALL', isSelected: _selectedCategoryId == null, onTap: () => _onCategorySelected(null));
                  }
                  final category = categoryProvider.categories[index - 1];
                  IconData iconData = Icons.star;
                  if (category['icon'] == 'restaurant') iconData = Icons.restaurant;
                  if (category['icon'] == 'camera_alt') iconData = Icons.camera_alt;
                  if (category['icon'] == 'location_on') iconData = Icons.location_on;
                  if (category['icon'] == 'celebration') iconData = Icons.celebration;
                  if (category['icon'] == 'music_note') iconData = Icons.music_note;

                  return _buildCategoryItem(
                    iconData, 
                    category['name'].toString().toUpperCase(), 
                    isSelected: _selectedCategoryId == category['id'],
                    onTap: () => _onCategorySelected(category['id'])
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategoryId == null ? 'Featured Curations' : 'Vendors',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('VIEW ALL', style: TextStyle(color: Colors.grey, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            // Vendors List
            if (vendorProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vendorProvider.vendors.isEmpty)
              const Center(child: Text('No vendors found in this category.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vendorProvider.vendors.length,
                itemBuilder: (context, index) {
                  final vendor = vendorProvider.vendors[index];
                  return _buildVendorCard(vendor);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1a365d) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1a365d).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(dynamic vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              vendor['user']['profile_image'] ?? 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800&q=80',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/catering.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(vendor['category']['name'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const Text('PREMIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(vendor['business_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(vendor['description'] ?? 'No description available.', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorDetailScreen(vendorId: vendor['id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a365d),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('VIEW DETAILS', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
