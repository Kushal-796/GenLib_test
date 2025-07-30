// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../widgets/app_drawer.dart';
// import 'book_detail_screen.dart';
//
// class UserHomeScreen extends StatefulWidget {
//   const UserHomeScreen({super.key});
//
//   @override
//   State<UserHomeScreen> createState() => _UserHomeScreenState();
// }
//
// class _UserHomeScreenState extends State<UserHomeScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   String? userName;
//
//   late Stream<QuerySnapshot> genreStream;
//   late Stream<QuerySnapshot> popularBooksStream;
//   late Stream<QuerySnapshot> availableBooksStream;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserName();
//     genreStream = FirebaseFirestore.instance.collection('books').snapshots();
//     popularBooksStream = FirebaseFirestore.instance
//         .collection('books')
//         .where('isAvailable', isEqualTo: true)
//         .limit(5)
//         .snapshots();
//     availableBooksStream = FirebaseFirestore.instance
//         .collection('books')
//         .where('isAvailable', isEqualTo: true)
//         .limit(10)
//         .snapshots();
//   }
//
//   Future<void> _fetchUserName() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid != null) {
//       final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         userName = doc['name'] ?? 'User';
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: const Color(0xFFF3FAF8),
//       drawer: AppDrawer(onToggleTheme: () {}),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.chevron_right, color: Color(0xFF00253A)),
//             onPressed: () {
//               Scaffold.of(context).openDrawer();
//             },
//           ),
//         ),
//         title: const Text(
//           "Home",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             color: Color(0xFF00253A),
//           ),
//         ),
//         actions: [
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('alerts')
//                 .where('userId', isEqualTo: userId)
//                 .where('isRead', isEqualTo: false)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
//
//               return Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.notifications, color: Color(0xFF00253A)),
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/alerts');
//                     },
//                   ),
//                   if (hasUnread)
//                     const Positioned(
//                       right: 10,
//                       top: 10,
//                       child: CircleAvatar(
//                         radius: 5,
//                         backgroundColor: Colors.red,
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Hi ${userName ?? ''}',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF00253A),
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 "We think you’ll like, based on your past preferences",
//                 style: TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//
//               const SizedBox(height: 20),
//               _buildPopularBooks(),
//               const SizedBox(height: 28),
//               _buildGenreCategories(),
//               const SizedBox(height: 28),
//               _buildAvailableBooks(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPopularBooks() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Popular Books',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF00253A),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 250,
//           child: StreamBuilder<QuerySnapshot>(
//             stream: popularBooksStream,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final books = snapshot.data?.docs ?? [];
//               return ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: books.length,
//                 itemBuilder: (context, index) {
//                   final data = books[index].data() as Map<String, dynamic>;
//                   final bookId = books[index].id;
//                   final title = data['title'] ?? 'Untitled';
//                   final author = data['author'] ?? 'Unknown';
//                   final isAvailable = data['isAvailable'] ?? false;
//                   final imageUrl = data['imageUrl'] as String?;
//
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => BookDetailScreen(
//                             bookId: bookId,
//                             title: title,
//                             author: author,
//                             isAvailable: isAvailable,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: 140,
//                       margin: const EdgeInsets.only(right: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           )
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                               child: imageUrl != null
//                                   ? Image.network(
//                                 imageUrl,
//                                 fit: BoxFit.cover,
//                               )
//                                   : Container(
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.book, size: 40),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   title,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF00253A),
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   author,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black54,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGenreCategories() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Categories',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF00253A),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 100,
//           child: StreamBuilder<QuerySnapshot>(
//             stream: genreStream,
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final genresSet = <String>{};
//               for (var doc in snapshot.data!.docs) {
//                 final genre = doc['genre'];
//                 if (genre != null && genre.toString().trim().isNotEmpty) {
//                   genresSet.add(genre);
//                 }
//               }
//               final genres = genresSet.toList();
//               final colors = [
//                 Colors.lightBlue.shade100,
//                 Colors.pink.shade100,
//                 Colors.purple.shade100,
//                 Colors.orange.shade100,
//                 Colors.green.shade100,
//                 Colors.yellow.shade100
//               ];
//               return ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: genres.length,
//                 itemBuilder: (context, index) {
//                   final genre = genres[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.pushNamed(
//                         context,
//                         '/genreBooks',
//                         arguments: genre,
//                       );
//                     },
//                     child: Container(
//                       width: 120,
//                       margin: const EdgeInsets.symmetric(horizontal: 8),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: colors[index % colors.length],
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           genre,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF00253A),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAvailableBooks() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Available Books',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF00253A),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pushNamed(context, '/bookList');
//               },
//               child: const Text(
//                 'View All',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 250,
//           child: StreamBuilder<QuerySnapshot>(
//             stream: availableBooksStream,
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final books = snapshot.data!.docs;
//               return ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: books.length,
//                 itemBuilder: (context, index) {
//                   final data = books[index].data() as Map<String, dynamic>;
//                   final bookId = books[index].id;
//                   final title = data['title'] ?? 'Untitled';
//                   final author = data['author'] ?? 'Unknown';
//                   final isAvailable = data['isAvailable'] ?? false;
//                   final imageUrl = data['imageUrl'] as String?;
//
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => BookDetailScreen(
//                             bookId: bookId,
//                             title: title,
//                             author: author,
//                             isAvailable: isAvailable,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: 140,
//                       margin: const EdgeInsets.only(right: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           )
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                               child: imageUrl != null
//                                   ? Image.network(
//                                 imageUrl,
//                                 fit: BoxFit.cover,
//                               )
//                                   : Container(
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.book, size: 40),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   title,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF00253A),
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   author,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black54,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/screens/chatbot_screen.dart';

import '../widgets/app_drawer.dart';
import 'book_detail_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;

  late Stream<QuerySnapshot> genreStream;
  late Stream<QuerySnapshot> popularBooksStream;
  late Stream<QuerySnapshot> availableBooksStream;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    genreStream = FirebaseFirestore.instance.collection('books').snapshots();
    popularBooksStream = FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .limit(5)
        .snapshots();
    availableBooksStream = FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .limit(10)
        .snapshots();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = doc['name'] ?? 'User';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      key: _scaffoldKey,
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
          "Home",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF00253A),
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('alerts')
                .where('userId', isEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Color(0xFF00253A)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/alerts');
                    },
                  ),
                  if (hasUnread)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hi ${userName ?? ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00253A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "We think you’ll like, based on your past preferences",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),
              _buildPopularBooks(),
              const SizedBox(height: 28),
              _buildGenreCategories(),
              const SizedBox(height: 28),
              _buildAvailableBooks(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: const Color(0xFF00253A),
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  Widget _buildPopularBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Books',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00253A),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
            stream: popularBooksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final books = snapshot.data?.docs ?? [];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final data = books[index].data() as Map<String, dynamic>;
                  final bookId = books[index].id;
                  final title = data['title'] ?? 'Untitled';
                  final author = data['author'] ?? 'Unknown';
                  final isAvailable = data['isAvailable'] ?? false;
                  final imageUrl = data['imageUrl'] as String?;

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
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
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
                              child: imageUrl != null
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 40),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildGenreCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00253A),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: StreamBuilder<QuerySnapshot>(
            stream: genreStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final genresSet = <String>{};
              for (var doc in snapshot.data!.docs) {
                final genre = doc['genre'];
                if (genre != null && genre.toString().trim().isNotEmpty) {
                  genresSet.add(genre);
                }
              }
              final genres = genresSet.toList();
              final colors = [
                Colors.lightBlue.shade100,
                Colors.pink.shade100,
                Colors.purple.shade100,
                Colors.orange.shade100,
                Colors.green.shade100,
                Colors.yellow.shade100
              ];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/genreBooks',
                        arguments: genre,
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          genre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00253A),
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
      ],
    );
  }

  Widget _buildAvailableBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Books',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00253A),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/bookList');
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
        SizedBox(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
            stream: availableBooksStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final books = snapshot.data!.docs;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final data = books[index].data() as Map<String, dynamic>;
                  final bookId = books[index].id;
                  final title = data['title'] ?? 'Untitled';
                  final author = data['author'] ?? 'Unknown';
                  final isAvailable = data['isAvailable'] ?? false;
                  final imageUrl = data['imageUrl'] as String?;

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
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
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
                              child: imageUrl != null
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 40),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
    );
  }
}
