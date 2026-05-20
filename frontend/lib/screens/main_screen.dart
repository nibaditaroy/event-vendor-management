import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'organizer/discover_screen.dart';
import 'organizer/bookings_screen.dart';
import 'organizer/profile_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isVendor = authProvider.userRole == 'vendor';

    final List<Widget> organizerScreens = [
      const DiscoverScreen(),
      const BookingsScreen(),
      const ProfileScreen(),
    ];

    final List<Widget> vendorScreens = [
      const VendorDashboardScreen(),
      const BookingsScreen(), // Reused for vendor history
      const ProfileScreen(),
    ];

    final screens = isVendor ? vendorScreens : organizerScreens;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1a365d),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: isVendor, // Show labels for vendor for clarity
        showUnselectedLabels: isVendor,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(isVendor ? Icons.dashboard_outlined : Icons.explore_outlined),
            activeIcon: Icon(isVendor ? Icons.dashboard : Icons.explore),
            label: isVendor ? 'Dashboard' : 'Discover',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
