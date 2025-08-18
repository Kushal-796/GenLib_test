import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';

class PenaltyCheckoutPage extends StatefulWidget {
  final String lendingRequestId;

  const PenaltyCheckoutPage({super.key, required this.lendingRequestId});

  @override
  State<PenaltyCheckoutPage> createState() => _PenaltyCheckoutPageState();
}

class _PenaltyCheckoutPageState extends State<PenaltyCheckoutPage> {
  late Razorpay _razorpay;
  DocumentSnapshot? lendingDetails;
  DocumentSnapshot? bookDetails;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchDetails();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final lendingDoc = await FirebaseFirestore.instance
          .collection('lending_requests')
          .doc(widget.lendingRequestId)
          .get();

      final bookId = lendingDoc['bookId'];

      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();

      setState(() {
        lendingDetails = lendingDoc;
        bookDetails = bookDoc;
      });
    } catch (e) {
      debugPrint('Error fetching details: $e');
    }
  }

  Future<void> _startPayment() async {
    final amount = lendingDetails!['penaltyAmount'];
    final title = bookDetails!['title'];

    var options = {
      'key': 'rzp_test_R6gPVI3YsAgFBw', // Replace with your Razorpay key
      'amount': amount * 100,
      'name': 'Library Penalty',
      'description': 'Penalty for "$title"',
      'prefill': {'contact': '', 'email': ''},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await FirebaseFirestore.instance
          .collection('lending_requests')
          .doc(widget.lendingRequestId)
          .update({'isPaid': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Payment Successful!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Payment Failed. Try again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💰 Wallet Selected: ${response.walletName}")),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      appBar: AppBar(
        title: const Text(
          'Penalty Checkout',
          style: TextStyle(color: Color(0xFF00253A), fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00253A)),
      ),
      body: (lendingDetails == null || bookDetails == null)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: bookDetails!['imageUrl'] != null &&
                      bookDetails!['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                    bookDetails!['imageUrl'],
                    width: 180,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 180,
                      height: 240,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      return loadingProgress == null
                          ? child
                          : Container(
                        width: 180,
                        height: 240,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  )
                      : Container(
                    width: 180,
                    height: 240,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '📕 Title: ${bookDetails!['title']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00253A)),
              ),
              const SizedBox(height: 10),
              Text(
                '✍️ Author: ${bookDetails!['author']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '🆔 Book ID: ${lendingDetails!['bookId']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '🕒 Lended on: ${_formatTimestamp(lendingDetails!['timestamp'])}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SlideAction(
                outerColor: Colors.indigo,
                innerColor: Colors.white,
                elevation: 1,
                sliderButtonIcon: const Icon(Icons.payment, color: Colors.black),
                text: 'Slide to Pay ₹${lendingDetails!['penaltyAmount']}',
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                onSubmit: _startPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
