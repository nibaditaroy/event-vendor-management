import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/service_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/review_provider.dart';

import 'screens/organizer/discover_screen.dart';
import 'screens/vendor/vendor_dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const EventVendorApp(),
    ),
  );
}

class EventVendorApp extends StatefulWidget {
  const EventVendorApp({super.key});

  @override
  State<EventVendorApp> createState() => _EventVendorAppState();
}

class _EventVendorAppState extends State<EventVendorApp> {
  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Vendor Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a365d),
          primary: const Color(0xFF1a365d),
          secondary: const Color(0xFFf3f4f6),
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) return const LoginScreen();
          return auth.userRole == 'vendor' 
            ? const VendorDashboardScreen() 
            : const DiscoverScreen();
        },
      ),
    );
  }
}
