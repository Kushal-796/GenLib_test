import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String author;
  final bool isAvailable;

  const BookDetailScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.isAvailable,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isLoading = false;
  bool _requestMade = false;
  bool _isInWishlist = false;
  String? _imageUrl;
  String _genre = 'Unknown';
  int _copies = 0;
  int _nob = 0; // number of books user has

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfRequestAlreadyMade();
    _fetchBookDetails();
    _checkIfInWishlist();
    _fetchUserBookCount();
  }

  Future<void> _fetchBookDetails() async {
    try {
      final doc = await _firestore.collection('books').doc(widget.bookId).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
          _imageUrl = data['imageUrl'];
        }
        _genre = data['genre'] ?? 'Unknown';
        _copies = data['count'] ?? 0;
        setState(() {});
      }
    } catch (e) {
      debugPrint("Failed to fetch book details: $e");
    }
  }

  Future<void> _checkIfRequestAlreadyMade() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final query = await _firestore
        .collection('lending_requests')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: widget.bookId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        _requestMade = true;
      });
    }
  }

  Future<void> _fetchUserBookCount() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nob = data['nob'] ?? 0;
      setState(() {});
    }
  }

  Future<void> _checkIfInWishlist() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final wishlist = userDoc.data()?['wishlist'] ?? [];

    setState(() {
      _isInWishlist = wishlist.contains(widget.bookId);
    });
  }

  Future<void> _toggleWishlist() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final wishlist = List<String>.from(userDoc.data()?['wishlist'] ?? []);

    if (_isInWishlist) {
      wishlist.remove(widget.bookId);
    } else {
      wishlist.add(widget.bookId);
    }

    await userRef.update({'wishlist': wishlist});

    setState(() {
      _isInWishlist = !_isInWishlist;
    });
  }

  Future<void> _sendBorrowRequest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      // Step 1: Add the lending request
      await _firestore.collection('lending_requests').add({
        'userId': user.uid,
        'bookId': widget.bookId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
        'isReturned': false,
      });

      // Step 2: Update the user's `nob` count
      final userSnap = await userRef.get();
      int currentNob = 0;
      if (userSnap.exists) {
        currentNob = userSnap.data()?['nob'] ?? 0;
      }

      await userRef.update({'nob': currentNob + 1});

      // Step 3: Show success
      setState(() {
        _requestMade = true;
        _nob = currentNob + 1; // Update UI state too
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📩 Request sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isBorrowDisabled = _requestMade || !widget.isAvailable || _nob >= 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAF8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF00253A), size: 32),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Book Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00253A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _imageUrl != null
                      ? Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                    },
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.menu_book, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00253A),
              ),
            ),
            const SizedBox(height: 12),
            Text("by ${widget.author}",
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            Text("Genre: $_genre", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Available Copies: $_copies", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Book ID: ${widget.bookId}",
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        isBorrowDisabled ? Icons.block : Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: isBorrowDisabled ? null : _sendBorrowRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBorrowDisabled
                            ? Colors.grey
                            : const Color(0xFF00253A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      label: Text(
                        isBorrowDisabled
                            ? (_nob >= 5 ? "Limit Reached" : "Request Made")
                            : "Borrow",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(_isInWishlist ? Icons.favorite : Icons.favorite_border),
                      label: Text(_isInWishlist ? "Remove" : "Add to Wishlist"),
                      onPressed: _toggleWishlist,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00253A),
                        side: const BorderSide(color: Color(0xFF00253A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
