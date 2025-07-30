import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/admin_app_drawer.dart';
import 'admin_available_books_screen.dart'; // <--- Imported screen to navigate back to

class AdminProcessedRequests extends StatelessWidget {
  const AdminProcessedRequests({super.key});

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'Unknown User';
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
    return 'Unknown User';
  }

  Future<String> _getBookTitle(String bookId) async {
    try {
      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        return bookDoc.data()?['title'] ?? 'Unknown Book';
      }
    } catch (e) {
      debugPrint('Error fetching book title: $e');
    }
    return 'Unknown Book';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminAvailableBooksScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3FAF8),
        drawer: AdminAppDrawer(),
        body: SafeArea(
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dad’s AppBar style
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Processed Requests',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00253A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main Content
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('lending_requests')
                          .where('status', whereIn: ['approved', 'rejected'])
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final requests = snapshot.data!.docs;

                        if (requests.isEmpty) {
                          return const Center(
                            child: Text(
                              'No processed requests.',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            final userId = request['userId'];
                            final bookId = request['bookId'];
                            final status = request['status'];
                            final isApproved = status == 'approved';

                            return FutureBuilder<List<String>>(
                              future: Future.wait([
                                _getUserName(userId),
                                _getBookTitle(bookId),
                              ]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: LinearProgressIndicator(),
                                  );
                                }

                                final userName = snapshot.data![0];
                                final bookTitle = snapshot.data![1];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                      isApproved ? Colors.green.shade100 : Colors.red.shade100,
                                      child: Icon(
                                        isApproved ? Icons.check : Icons.close,
                                        color: isApproved ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    title: Text(
                                      bookTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF00253A),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text("User: $userName"),
                                        const SizedBox(height: 6),
                                        Chip(
                                          label: Text(
                                            status.toUpperCase(),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: isApproved ? Colors.green : Colors.red,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
      ),
    );
  }
}
