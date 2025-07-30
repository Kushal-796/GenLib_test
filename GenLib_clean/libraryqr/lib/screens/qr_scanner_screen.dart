import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/screens/user_home_screen.dart';
import 'book_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _controller.start(); // Ensure scanner starts on load
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isProcessing) {
      _controller.start(); // Resume scanning when returning from minimized
    }
  }

  Future<void> _handleQRCode(String bookId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _controller.stop(); // Stop scanning after detection

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final bookData = doc.data();
        final title = bookData['title'] ?? 'Untitled';
        final author = bookData['author'] ?? 'Unknown Author';
        final isAvailable = bookData['isAvailable'];

        // 👇 Wait for Book Detail to complete
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(
              bookId: bookId,
              title: title,
              author: author,
              isAvailable: isAvailable,
            ),
          ),
        );

        // 👇 Restart scanner when back
        if (mounted) _controller.start();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚫 Book not found. Please try again."),
            backgroundColor: Colors.redAccent,
          ),
        );
        _controller.start(); // Resume scan if book not found
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      _controller.start(); // Resume scan on error
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3FAF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF00253A),
          title: const Text('QR Scanner', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserHomeScreen()),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            // QR Scanner Camera
            MobileScanner(
              controller: _controller,
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                final String? code = barcode.rawValue;
                if (code != null) {
                  _handleQRCode(code);
                }
              },
            ),

            // QR Frame + Animation
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _animationController.value * 220),
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Prompt
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "📸 Align QR within the frame",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(1, 1),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.indigo),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
