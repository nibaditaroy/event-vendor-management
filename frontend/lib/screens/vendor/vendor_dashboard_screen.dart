import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/category_provider.dart';
import '../../services/api_service.dart';
import '../../providers/notification_provider.dart';
import '../common/notifications_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
      Provider.of<VendorProvider>(context, listen: false).fetchCurrentVendor();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('VENDOR PORTAL', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1a365d),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1a365d),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'REQUESTS'),
            Tab(text: 'SERVICES'),
            Tab(text: 'INFO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildServicesTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1 ? FloatingActionButton.extended(
        onPressed: () => _showServiceModal(context),
        backgroundColor: const Color(0xFF1a365d),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD SERVICE', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }

  Widget _buildRequestsTab() {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;
    
    final activeBookings = bookings.where((b) => b['status'] == 'pending' || b['status'] == 'confirmed').toList();
    final completedBookings = bookings.where((b) => b['status'] == 'completed').toList();

    return RefreshIndicator(
      onRefresh: () => bookingProvider.fetchBookings(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSummaryStats(bookings),
          const SizedBox(height: 32),
          const Text('ACTIVE DEALS & REQUESTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          if (bookingProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (activeBookings.isEmpty && completedBookings.isEmpty)
            _buildEmptyState(Icons.inbox_outlined, 'No deals yet', 'New booking requests will appear here.')
          else ...[
            ...activeBookings.map((b) => _buildRequestCard(b)),
            if (completedBookings.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text('WORK DONE / HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 16),
              ...completedBookings.map((b) => _buildRequestCard(b)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    return RefreshIndicator(
      onRefresh: () => serviceProvider.fetchServices(),
      child: serviceProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('YOUR CURATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 16),
              if (serviceProvider.services.isEmpty)
                _buildEmptyState(Icons.room_service_outlined, 'No services yet', 'Add services to showcase your expertise.')
              else
                ...serviceProvider.services.map((s) => _buildServiceCard(s)),
            ],
          ),
    );
  }

  Widget _buildProfileTab() {
    final vendorProvider = Provider.of<VendorProvider>(context);
    final vendor = vendorProvider.selectedVendor;

    if (vendorProvider.isLoading || vendor == null) return const Center(child: CircularProgressIndicator());

    final nameController = TextEditingController(text: vendor['business_name']);
    final descController = TextEditingController(text: vendor['description']);
    final addrController = TextEditingController(text: vendor['address']);
    String? currentImage = vendor['user']['profile_image'];

    return StatefulBuilder(
      builder: (context, setProfileState) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('VENDOR PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade100,
                      child: currentImage != null 
                        ? Image.network(currentImage!, fit: BoxFit.cover) 
                        : const Icon(Icons.business, size: 60, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    bottom: 12, right: 12,
                    child: FloatingActionButton.small(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setProfileState(() { _isUploading = true; });
                          final res = await ApiService.uploadImage(image);
                          final data = jsonDecode(res.body);
                          if (data['success']) {
                            setProfileState(() {
                              currentImage = data['data']['url'];
                              _isUploading = false;
                            });
                          }
                        }
                      },
                      backgroundColor: const Color(0xFF1a365d),
                      child: _isUploading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                      child: const Text('PREMIUM PARTNER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1a365d))),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(vendor['business_name'] ?? 'BUSINESS NAME', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                  const Icon(Icons.stars, color: Colors.amber, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(vendor['address'] ?? 'Location not set', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              Text(vendor['description'] ?? 'No description provided.', style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5)),
            ],
          ),
          const SizedBox(height: 32),
          _buildInputField('BUSINESS NAME', 'e.g. Elegant Events', nameController),
          const SizedBox(height: 16),
          const Text('BUSINESS CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Consumer<CategoryProvider>(
            builder: (context, catProvider, _) {
              final categories = catProvider.categories;
              final currentCatId = vendor['category_id'];
              final bool isValidValue = categories.any((c) => c['id'] == currentCatId);
              
              return DropdownButtonFormField<int>(
                value: isValidValue ? currentCatId : null,
                decoration: InputDecoration(
                  filled: true, 
                  fillColor: Colors.grey.shade50, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)), 
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200))
                ),
                items: categories.map((c) => DropdownMenuItem<int>(
                  value: c['id'], 
                  child: Text(c['name'])
                )).toList(),
                onChanged: (val) => vendor['category_id'] = val,
                hint: const Text('Select Category'),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildInputField('DESCRIPTION', 'Tell organizers about your work', descController, maxLines: 3),
          const SizedBox(height: 16),
          _buildInputField('ADDRESS', 'Business location', addrController),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final success = await vendorProvider.updateProfile({
                  'business_name': nameController.text,
                  'category_id': vendor['category_id'],
                  'description': descController.text,
                  'address': addrController.text,
                  'profile_image': currentImage
                });
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a365d), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('SAVE CHANGES'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryStats(List<dynamic> bookings) {
    int pendingCount = bookings.where((b) => b['status'] == 'pending').length;
    int confirmedCount = bookings.where((b) => b['status'] == 'confirmed').length;
    int completedCount = bookings.where((b) => b['status'] == 'completed').length;
    
    double totalEarnings = bookings.fold<double>(0.0, (double sum, b) => sum + (double.tryParse(b['total_amount'].toString()) ?? 0.0));
    double paidAmount = bookings.where((b) => b['payment_status'] == 'paid').fold<double>(0.0, (double sum, b) => sum + (double.tryParse(b['total_amount'].toString()) ?? 0.0));
    double unpaidAmount = bookings.where((b) => b['payment_status'] == 'unpaid' && b['status'] != 'cancelled').fold<double>(0.0, (double sum, b) => sum + (double.tryParse(b['total_amount'].toString()) ?? 0.0));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a365d), Color(0xFF2a4365)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1a365d).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Pending', pendingCount.toString()),
              _buildStat('Confirmed', confirmedCount.toString()),
              _buildStat('Work Done', completedCount.toString(), color: Colors.blueAccent),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Paid', 'TK ${paidAmount.toStringAsFixed(0)}', color: Colors.greenAccent),
              _buildStat('Unpaid', 'TK ${unpaidAmount.toStringAsFixed(0)}', color: Colors.orangeAccent),
              _buildStat('Total Val', 'TK ${totalEarnings.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildRequestCard(dynamic booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text((booking['service']?['title'] ?? 'Service').toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), Text('TK ${booking['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1a365d)))]),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: booking['organizer']['profile_image'] != null 
                  ? NetworkImage(booking['organizer']['profile_image']) 
                  : null,
                child: booking['organizer']['profile_image'] == null 
                  ? const Icon(Icons.person, size: 18, color: Colors.grey) 
                  : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['organizer']['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(booking['event_date'].toString().split('T')[0], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (booking['payment_status'] ?? 'unpaid') == 'paid' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (booking['payment_status'] ?? 'unpaid').toUpperCase(),
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: (booking['payment_status'] ?? 'unpaid') == 'paid' ? Colors.green : Colors.orange),
                          ),
                        ),
                        if (booking['review'] != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 10, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(booking['review']['rating'].toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  booking['service']?['thumbnail'] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=100&q=80',
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 45, height: 45, color: Colors.grey.shade100, child: const Icon(Icons.image, size: 18, color: Colors.grey)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (booking['status'] == 'pending') ...[
                Expanded(child: OutlinedButton(onPressed: () => _updateStatus(booking['id'], 'cancelled'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: BorderSide(color: Colors.red.shade100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('DECLINE'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => _updateStatus(booking['id'], 'confirmed'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a365d), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('ACCEPT'))),
              ] else if (booking['status'] == 'confirmed' && (booking['payment_status'] ?? 'unpaid') != 'paid') ...[
                Expanded(child: ElevatedButton(onPressed: () => _updatePaymentStatus(booking['id'], 'paid'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('MARK AS PAID'))),
              ] else if (booking['status'] == 'confirmed' && (booking['payment_status'] ?? 'unpaid') == 'paid') ...[
                 Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Text('WAITING FOR COMPLETION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blue.shade700, letterSpacing: 1)))),
              ] else if (booking['status'] == 'completed') ...[
                 Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Text('DEAL FINISHED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green.shade700, letterSpacing: 1)))),
              ] else ...[
                 Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)), child: Text(booking['status'].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))),
              ],
              if (booking['status'] != 'completed') ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    final phone = booking['organizer']['phone'];
                    if (phone != null) _callNumber(phone);
                  },
                  icon: const Icon(Icons.call, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _buildServiceCard(dynamic service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(service['thumbnail'] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=200&q=80', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade100, child: const Icon(Icons.image_outlined, color: Colors.grey)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(service['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(service['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Text('TK ${service['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1a365d)))])),
          Column(
            children: [
              IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showServiceModal(context, service: service)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _confirmDelete(service['id'])),
            ],
          )
        ],
      ),
    );
  }

  void _showServiceModal(BuildContext context, {dynamic service}) {
    final titleController = TextEditingController(text: service?['title']);
    final priceController = TextEditingController(text: service?['price']?.toString());
    final descController = TextEditingController(text: service?['description']);
    String? imageUrl = service?['thumbnail'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setMState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service == null ? 'ADD SERVICE' : 'EDIT SERVICE', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildInputField('TITLE', 'e.g. Photography', titleController),
                const SizedBox(height: 16),
                _buildPhotoUploader(imageUrl, (url) => setMState(() => imageUrl = url)),
                const SizedBox(height: 16),
                _buildInputField('PRICE', '0.0', priceController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildInputField('DESCRIPTION', 'Details...', descController, maxLines: 3),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final data = {'title': titleController.text, 'price': double.tryParse(priceController.text) ?? 0.0, 'description': descController.text, 'thumbnail': imageUrl};
                      final success = service == null 
                        ? await Provider.of<ServiceProvider>(context, listen: false).createService(data) 
                        : await Provider.of<ServiceProvider>(context, listen: false).updateService(service['id'], data);
                      if (success) { Navigator.pop(context); }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1a365d), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(service == null ? 'CREATE' : 'UPDATE'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploader(String? url, Function(String) onUpload) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PHOTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 19 / 6,
          child: InkWell(
            onTap: () async {
              final image = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() => _isUploading = true);
                final res = await ApiService.uploadImage(image);
                final data = jsonDecode(res.body);
                if (data['success']) onUpload(data['data']['url']);
                setState(() => _isUploading = false);
              }
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: url != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.cover)) : const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(int id) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Delete?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')), TextButton(onPressed: () { Provider.of<ServiceProvider>(context, listen: false).deleteService(id); Navigator.pop(context); }, child: const Text('YES'))]));
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 8), TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200))))]);
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 60), child: Column(children: [Icon(icon, size: 48, color: Colors.grey.shade300), const SizedBox(height: 16), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)])));
  }

  void _updateStatus(int id, String status) async {
    final success = await Provider.of<BookingProvider>(context, listen: false).updateStatus(id, status);
    if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking $status!')));
  }

  void _updatePaymentStatus(int id, String status) async {
    final success = await Provider.of<BookingProvider>(context, listen: false).updatePaymentStatus(id, status);
    if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment marked as $status!')));
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
