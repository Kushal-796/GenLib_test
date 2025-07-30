import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';

class UserBookListScreen extends StatelessWidget {
  final String genre;

  const UserBookListScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final booksStream = FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .where('genre', isEqualTo: genre)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAF8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF00253A), size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          genre,
          style: const TextStyle(
            color: Color(0xFF00253A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: booksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No books found in this genre."),
                );
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
                  final imageUrl = book['imageUrl'] as String?;
                  final title = book['title'] ?? 'Untitled';
                  final author = book['author'] ?? 'Unknown';
                  final bookId = book['bookId'] ?? books[index].id;
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                      child: Icon(Icons.book, size: 40, color: Colors.grey));
                                },
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF00253A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
