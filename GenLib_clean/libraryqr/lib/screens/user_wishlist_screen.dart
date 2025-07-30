import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/widgets/app_drawer.dart';
import 'book_detail_screen.dart';

class UserWishlistScreen extends StatefulWidget {
  const UserWishlistScreen({super.key});

  @override
  State<UserWishlistScreen> createState() => _UserWishlistScreenState();
}

class _UserWishlistScreenState extends State<UserWishlistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> wishlistBookIds = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final data = userDoc.data();
    if (data != null && data.containsKey('wishlist')) {
      setState(() {
        wishlistBookIds = List<String>.from(data['wishlist']);
      });
    }
  }

  Stream<QuerySnapshot> _wishlistBooksStream() {
    if (wishlistBookIds.isEmpty) {
      return const Stream<QuerySnapshot>.empty();
    }

    return _firestore
        .collection('books')
        .where(FieldPath.documentId, whereIn: wishlistBookIds)
        .snapshots();
  }

  Future<void> _removeFromWishlist(String bookId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'wishlist': FieldValue.arrayRemove([bookId]),
    });

    setState(() {
      wishlistBookIds.remove(bookId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Removed from wishlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3FAF8),
        drawer: AppDrawer(onToggleTheme: () {}),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00253A)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: const Text(
            'My Wishlist',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00253A),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: _wishlistBooksStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Your wishlist is empty.'));
              }

              final books = snapshot.data!.docs;

              return GridView.builder(
                itemCount: books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) {
                  final book = books[index].data() as Map<String, dynamic>;
                  final bookId = books[index].id;
                  final title = book['title'] ?? 'Untitled';
                  final author = book['author'] ?? 'Unknown';
                  final imageUrl = book['imageUrl'] ?? '';
                  final isAvailable = book['isAvailable'] ?? true;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
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
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.book, size: 40, color: Colors.grey),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : const Center(child: CircularProgressIndicator());
                                },
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF00253A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _removeFromWishlist(bookId),
                                    icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.white),
                                    label: const Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00253A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      textStyle: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
