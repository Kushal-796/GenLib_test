import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/screens/book_detail_screen.dart';
import 'package:libraryqr/widgets/app_drawer.dart';
import '../widgets/notification_bell.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Stream<QuerySnapshot> booksStream;
  String? selectedGenre;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetBookStream();
    _searchController.addListener(() => setState(() {}));
  }

  void _resetBookStream() {
    booksStream = FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3FAF8),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00253A), size: 32),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            'Available Books',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00253A),
            ),
          ),
          centerTitle: true,
          actions: [
            NotificationBell(
              onTap: () {
                Navigator.pushNamed(context, '/alerts');
              },
            ),
          ],
        ),
        drawer: AppDrawer(onToggleTheme: () {}),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Search Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by title or author...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Available Books',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00253A),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: booksStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No books available right now."));
                      }

                      final query = _searchController.text.trim().toLowerCase();
                      final books = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = (data['title'] ?? '').toString().toLowerCase();
                        final author = (data['author'] ?? '').toString().toLowerCase();
                        return title.contains(query) || author.contains(query);
                      }).toList();

                      if (books.isEmpty) {
                        return const Center(child: Text("No matching books found."));
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index].data() as Map<String, dynamic>;
                          final bookId = books[index].id;
                          final title = book['title'] ?? 'Untitled';
                          final author = book['author'] ?? 'Unknown';
                          final isAvailable = book['isAvailable'] ?? false;
                          final imageUrl = book['imageUrl'] ?? '';

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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.book, size: 40, color: Colors.grey),
                                        loadingBuilder: (context, child, loadingProgress) {
                                          return loadingProgress == null
                                              ? child
                                              : const Center(child: CircularProgressIndicator());
                                        },
                                      )
                                          : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: Icon(Icons.book, size: 40, color: Colors.grey)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
