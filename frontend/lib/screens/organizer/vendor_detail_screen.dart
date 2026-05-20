import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/review_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorDetailScreen extends StatefulWidget {
  final int vendorId;
  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final Set<int> _selectedServiceIds = {};
  final _eventDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).fetchVendorById(widget.vendorId);
      Provider.of<ReviewProvider>(context, listen: false).fetchVendorReviews(widget.vendorId);
    });
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    final vendor = vendorProvider.selectedVendor;

    if (vendorProvider.isLoading || vendor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(vendor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(vendor),
                  const SizedBox(height: 32),
                  const Text('PHILOSOPHY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text(vendor['description'] ?? 'No description provided.', style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
                  const SizedBox(height: 40),
                  const Text('SERVICES & CURATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _buildServicesList(vendor['services'] ?? []),
                  const SizedBox(height: 40),
                  const Text('REVIEWS & FEEDBACK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _buildReviewsList(),
                  const SizedBox(height: 40),
                  _buildBookingForm(vendor),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic vendor) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1a365d),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              vendor['user']['profile_image'] ?? 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/catering.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic vendor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('PREMIUM PARTNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${vendor['rating'] ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(vendor['business_name'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(vendor['address'] ?? 'Remote', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            if (vendor['user']['phone'] != null)
              IconButton(
                onPressed: () => _callNumber(vendor['user']['phone']),
                icon: const Icon(Icons.call, color: Color(0xFF1a365d)),
                tooltip: 'Call Vendor',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesList(List<dynamic> services) {
    if (services.isEmpty) return const Text('No services listed.');
    
    return Column(
      children: services.map((service) {
        bool isSelected = _selectedServiceIds.contains(service['id']);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedServiceIds.remove(service['id']);
            } else {
              _selectedServiceIds.add(service['id']);
            }
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1a365d).withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF1a365d) : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    service['thumbnail'] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=100&q=80',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(service['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('TK ${service['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1a365d))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingForm(dynamic vendor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SECURE CURATION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInputField(
            'EVENT DATE', 
            'YYYY-MM-DD', 
            _eventDateController, 
            icon: Icons.calendar_today,
            suffixIcon: IconButton(
              icon: const Icon(Icons.date_range, color: Color(0xFF1a365d)),
              onPressed: () => _selectDate(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField('LOCATION', 'Manhattan, NY', _locationController, icon: Icons.location_on_outlined),
          const SizedBox(height: 20),
          _buildInputField('SPECIAL NOTES', 'Any specific requests...', _noteController, maxLines: 3),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a365d),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SEND BOOKING REQUEST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1a365d),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildReviewsList() {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    if (reviewProvider.isLoading) return const Center(child: CircularProgressIndicator());
    if (reviewProvider.vendorReviews.isEmpty) return const Text('No reviews yet. Be the first to rate!', style: TextStyle(color: Colors.grey));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviewProvider.vendorReviews.length,
      itemBuilder: (context, index) {
        final review = reviewProvider.vendorReviews[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundImage: review['organizer']['profile_image'] != null ? NetworkImage(review['organizer']['profile_image']) : null, child: review['organizer']['profile_image'] == null ? const Icon(Icons.person, size: 16) : null),
                  const SizedBox(width: 12),
                  Text(review['organizer']['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < review['rating'] ? Colors.orange : Colors.grey.shade300))),
                ],
              ),
              const SizedBox(height: 12),
              Text(review['comment'], style: const TextStyle(color: Colors.black87, height: 1.4)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {IconData? icon, int maxLines = 1, bool readOnly = false, VoidCallback? onTap, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  void _submitBooking() async {
    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one service')));
      return;
    }
    if (_eventDateController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in the date and location')));
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    
    bool allSuccess = true;
    for (int serviceId in _selectedServiceIds) {
      final selectedService = vendorProvider.selectedVendor!['services'].firstWhere((s) => s['id'] == serviceId);

      final success = await bookingProvider.createBooking({
        'vendor_id': widget.vendorId,
        'service_id': serviceId,
        'event_date': _eventDateController.text,
        'event_location': _locationController.text,
        'special_note': _noteController.text,
        'total_amount': selectedService['price'],
      });
      if (!success) allSuccess = false;
    }

    if (allSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All booking requests sent successfully!')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Some booking requests failed to send.')));
    }
  }

  void _updateStatus(int id, String status) async {
    final success = await Provider.of<BookingProvider>(context, listen: false).updateStatus(id, status);
    if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking $status!')));
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
