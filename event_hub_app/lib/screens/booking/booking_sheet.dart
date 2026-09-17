import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class BookingSheet extends StatefulWidget {
  final EventModel event;

  const BookingSheet({super.key, required this.event});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _notesController = TextEditingController();

  int _ticketsCount = 1;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ticketsCount > widget.event.availableSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${widget.event.availableSeats} tickets remaining!'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();
    final bookingsProv = context.read<BookingsProvider>();

    final user = auth.currentUser;
    final userId = user?.id ?? 'usr_guest';

    final booking = await bookingsProv.createBooking(
      eventId: widget.event.id,
      userId: userId,
      userName: _nameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPhone: _phoneController.text.trim(),
      ticketsCount: _ticketsCount,
      notes: _notesController.text.trim(),
      token: auth.token,
    );

    setState(() => _isProcessing = false);

    if (booking != null && mounted) {
      Navigator.pop(context); // Close sheet
      _showBookingSuccessDialog(booking);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingsProv.errorMessage ?? 'Booking failed. Try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showBookingSuccessDialog(BookingModel booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 54),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Your seats for "${booking.eventTitle}" are booked.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _confirmRow('Booking Ref', booking.bookingReference, isBold: true),
                    const Divider(height: 16),
                    _confirmRow('Tickets', '${booking.ticketsCount} Person(s)'),
                    _confirmRow('Total Paid', booking.totalPrice == 0 ? 'Free' : '\$${booking.totalPrice.toStringAsFixed(2)}'),
                    _confirmRow('Date', booking.eventDate),
                    _confirmRow('Time', booking.eventTime),
                    _confirmRow('Location', booking.eventLocation),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('View in My Bookings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? AppTheme.primary : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPrice = widget.event.price * _ticketsCount;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Complete Your Booking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.event.title,
                style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Ticket Quantity Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          widget.event.price == 0 ? 'Free event' : '\$${widget.event.price.toStringAsFixed(2)} per ticket',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _ticketsCount > 1
                              ? () => setState(() => _ticketsCount--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          color: AppTheme.primary,
                        ),
                        Text(
                          '$_ticketsCount',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          onPressed: _ticketsCount < widget.event.availableSeats
                              ? () => setState(() => _ticketsCount++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Inputs
              CustomTextField(
                controller: _nameController,
                label: 'Attendee Full Name',
                hint: 'Your Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _emailController,
                label: 'Confirmation Email',
                hint: 'you@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _notesController,
                label: 'Special Requests / Notes (Optional)',
                hint: 'Dietary requirements, accessibility needs, etc.',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Total Summary & Submit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        totalPrice == 0 ? 'Free' : '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Confirm & Book', style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
