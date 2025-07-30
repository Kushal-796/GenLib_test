import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/widgets/app_drawer.dart';
import 'book_detail_screen.dart';
import '../widgets/notification_bell.dart';
import 'book_list_screen.dart';

class UserExploreScreen extends StatefulWidget {
  const UserExploreScreen({super.key});

  @override
  State<UserExploreScreen> createState() => _UserExploreScreenState();
}

class _UserExploreScreenState extends State<UserExploreScreen> {
  String? selectedGenre;
  late Stream<QuerySnapshot> booksStream;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetBookStream();
    _searchController.addListener(_applySearchFilter);
  }

  void _resetBookStream() {
    booksStream = FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  void filterBooksByGenre(String? genre) {
    setState(() {
      if (selectedGenre == genre) {
        selectedGenre = null;
        _resetBookStream();
      } else {
        selectedGenre = genre;
        booksStream = FirebaseFirestore.instance
            .collection('books')
            .where('genre', isEqualTo: genre)
            .where('isAvailable', isEqualTo: true)
            .snapshots();
      }
    });
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty && selectedGenre == null) {
        _resetBookStream();
      } else {
        booksStream = FirebaseFirestore.instance
            .collection('books')
            .where('isAvailable', isEqualTo: true)
            .snapshots();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
        body: SafeArea(
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dad's AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                      ),
                      const Expanded(
                        child: Text(
                          "Explore",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00253A),
                          ),
                        ),
                      ),
                      NotificationBell(
                        onTap: () {
                          Navigator.pushNamed(context, '/alerts');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main UI
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Box
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
                              hintText: 'Title, author or topic',
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Categories
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00253A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 45,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('books').snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final genresSet = <String>{};
                              for (var doc in snapshot.data!.docs) {
                                final genre = doc['genre'] as String?;
                                if (genre != null && genre.isNotEmpty) {
                                  genresSet.add(genre);
                                }
                              }
                              final genres = genresSet.toList();
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: genres.length,
                                itemBuilder: (context, index) {
                                  final genre = genres[index];
                                  final isSelected = genre == selectedGenre;
                                  return GestureDetector(
                                    onTap: () => filterBooksByGenre(genre),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF00253A) : Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Center(
                                        child: Text(
                                          genre,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF00253A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedGenre ?? 'All Books',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00253A),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (selectedGenre == null || selectedGenre == 'All') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const BookListScreen()),
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    '/genreBooks',
                                    arguments: selectedGenre!,
                                  );
                                }
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Books Grid
                        SizedBox(
                          height: screenHeight * 0.6,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: booksStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text("No books found in this category."));
                              }
                              final books = snapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final title = data['title']?.toString().toLowerCase() ?? '';
                                final author = data['author']?.toString().toLowerCase() ?? '';
                                final query = _searchController.text.trim().toLowerCase();
                                return title.contains(query) || author.contains(query);
                              }).toList();
                              if (books.isEmpty) {
                                return const Center(child: Text("No matching books found."));
                              }
                              return GridView.builder(
                                itemCount: books.length,
                                physics: const BouncingScrollPhysics(),
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
                                  final isAvailable = book['isAvailable'] ?? true;
                                  final imageUrl = book['imageUrl'] as String?;

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
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                              child: (imageUrl != null && imageUrl.isNotEmpty)
                                                  ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, progress) {
                                                  return progress == null
                                                      ? child
                                                      : const Center(child: CircularProgressIndicator());
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.book, size: 40, color: Colors.grey);
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF00253A),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  author,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
