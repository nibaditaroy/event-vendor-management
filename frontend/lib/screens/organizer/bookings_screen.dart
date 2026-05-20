import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/review_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('MY BOOKINGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black)),
        centerTitle: true,
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.bookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: bookingProvider.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookingProvider.bookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No bookings yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Your curated events will appear here.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    Color statusColor = Colors.orange;
    if (booking['status'] == 'confirmed') statusColor = Colors.green;
    if (booking['status'] == 'completed') statusColor = Colors.blue;
    if (booking['status'] == 'cancelled') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((booking['service']?['title'] ?? 'Service').toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(booking['status'].toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40, height: 40,
                  color: Colors.grey.shade100,
                  child: booking['vendor']?['user']?['profile_image'] != null 
                    ? Image.network(booking['vendor']['user']['profile_image'], fit: BoxFit.cover) 
                    : const Icon(Icons.business, size: 20, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['vendor']['business_name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(booking['event_location'] ?? 'Location not set', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  booking['service']?['thumbnail'] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=100&q=80',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade100, child: const Icon(Icons.image, size: 20, color: Colors.grey)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(booking['event_date'].toString().split('T')[0], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              Text('Total: TK ${booking['total_amount']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1a365d))),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TK ${booking['total_amount']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone_outlined, color: Colors.blue),
                    onPressed: () {
                      final phone = booking['vendor']['user']['phone'];
                      if (phone != null) _callNumber(phone);
                    },
                  ),
                  OutlinedButton(
                    onPressed: () => _showDetails(context, booking),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('DETAILS', style: TextStyle(fontSize: 12, color: Colors.black)),
                  ),
                  if (booking['status'] == 'confirmed' && (booking['payment_status'] ?? 'unpaid') == 'paid') ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateStatus(booking['id'], 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('MARK AS COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  if (booking['status'] == 'completed' && booking['review'] == null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showRatingModal(context, booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('RATE NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
  void _showDetails(BuildContext context, dynamic booking) {
    Color statusColor = Colors.orange;
    if (booking['status'] == 'confirmed') statusColor = Colors.green;
    if (booking['status'] == 'completed') statusColor = Colors.blue;
    if (booking['status'] == 'cancelled') statusColor = Colors.red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('BOOKING DETAILS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(booking['status'].toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 70, height: 70,
                            color: Colors.grey.shade100,
                            child: booking['vendor']['user']['profile_image'] != null 
                              ? Image.network(booking['vendor']['user']['profile_image'], fit: BoxFit.cover) 
                              : const Icon(Icons.business, size: 30, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking['vendor']['business_name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.verified, size: 14, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text('Verified Partner', style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Image.network(
                            booking['service']?['thumbnail'] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80',
                            width: double.infinity, height: 200, fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
                              ),
                              child: Text(booking['service']?['title'] ?? 'Service', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('EVENT LOGISTICS'),
                    _buildDetailItem(Icons.calendar_month, 'Date', booking['event_date'].toString().split('T')[0]),
                    _buildDetailItem(Icons.location_on, 'Location', booking['event_location'] ?? 'Not set'),
                    _buildDetailItem(Icons.people, 'Expected Guests', (booking['guest_count'] ?? 'Not specified').toString()),
                    const SizedBox(height: 24),
                    _buildSectionHeader('FINANCIALS & CONTACT'),
                    _buildDetailItem(Icons.payments, 'Total Amount', 'TK ${booking['total_amount']}', isPrimary: true),
                    _buildDetailItem(
                      Icons.phone, 
                      'Contact Vendor', 
                      booking['vendor']['user']['phone'] ?? 'No phone listed',
                      action: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () {
                          final phone = booking['vendor']['user']['phone'];
                          if (phone != null) _callNumber(phone);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (booking['special_note'] != null && booking['special_note'].toString().isNotEmpty) ...[
                      _buildSectionHeader('SPECIAL NOTES'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                        child: Text(booking['special_note'], style: const TextStyle(color: Colors.black87, height: 1.5)),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a365d),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {bool isPrimary = false, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isPrimary ? const Color(0xFF1a365d).withOpacity(0.1) : Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: isPrimary ? const Color(0xFF1a365d) : Colors.black54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500, color: isPrimary ? const Color(0xFF1a365d) : Colors.black87)),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
  void _showRatingModal(BuildContext context, dynamic booking) {
    double selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setRState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RATE VENDOR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('How was your experience with ${booking['vendor']['business_name']}?', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.orange, size: 40),
                  onPressed: () => setRState(() => selectedRating = index + 1.0),
                )),
              ),
              const SizedBox(height: 24),
              const Text('YOUR COMMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a comment')));
                      return;
                    }
                    final success = await Provider.of<ReviewProvider>(context, listen: false).submitReview(
                      booking['id'],
                      booking['vendor_id'],
                      selectedRating,
                      commentController.text,
                    );
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a365d),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SUBMIT REVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(int id, String status) async {
    final success = await Provider.of<BookingProvider>(context, listen: false).updateStatus(id, status);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking marked as $status!')));
    }
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
