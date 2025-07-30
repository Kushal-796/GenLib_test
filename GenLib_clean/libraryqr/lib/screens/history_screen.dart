import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/screens/login_screen.dart';
import 'package:libraryqr/screens/alerts_screen.dart';
import 'package:libraryqr/screens/user_home_screen.dart';
import 'package:libraryqr/widgets/app_drawer.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HistoryScreen({super.key, required this.onToggleTheme});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchReturnedBooks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final lendingSnapshot = await _firestore
        .collection('lending_requests')
        .where('userId', isEqualTo: user.uid)
        .where('isReturned', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> history = [];

    for (var doc in lendingSnapshot.docs) {
      final lendingData = doc.data();
      final bookId = lendingData['bookId'];

      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      final bookData = bookDoc.data();

      if (bookData != null) {
        history.add({
          'title': bookData['title'],
          'author': bookData['author'],
          'timestamp': lendingData['timestamp'],
        });
      }
    }

    return history;
  }

  Stream<bool> hasUnreadAlerts() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
        drawer: AppDrawer(onToggleTheme: widget.onToggleTheme),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00253A)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            'History',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Color(0xFF00253A),
            ),
          ),
          actions: [
            StreamBuilder<bool>(
              stream: hasUnreadAlerts(),
              builder: (context, snapshot) {
                final hasUnread = snapshot.data ?? false;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Color(0xFF00253A)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AlertsScreen()),
                        );
                      },
                    ),
                    if (hasUnread)
                      const Positioned(
                        right: 11,
                        top: 11,
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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReturnedBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return const Center(
                child: Text(
                  '📚 No returned books yet!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final formattedDate = item['timestamp'] != null
                    ? (item['timestamp'] as Timestamp).toDate()
                    : DateTime.now();

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.indigo),
                    title: Text(
                      item['title'] ?? 'Unknown Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF00253A),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'by ${item['author'] ?? 'Unknown Author'}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Returned on: ${formattedDate.day}/${formattedDate.month}/${formattedDate.year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: const Chip(
                      label: Text('RETURNED', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
