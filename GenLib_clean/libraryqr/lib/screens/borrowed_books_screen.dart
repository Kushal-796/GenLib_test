import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:libraryqr/widgets/app_drawer.dart';
import 'package:libraryqr/screens/user_home_screen.dart';

class BorrowedBooksScreen extends StatefulWidget {
  const BorrowedBooksScreen({Key? key}) : super(key: key);

  @override
  State<BorrowedBooksScreen> createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _sendReturnRequest(String lendingRequestId, String bookId) async {
    try {
      final userId = user?.uid;
      if (userId == null) throw Exception("User not logged in");

      final penaltySnapshot = await FirebaseFirestore.instance
          .collection('penalties')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('isPaid', isEqualTo: false)
          .limit(1)
          .get();

      String? penaltyId;
      if (penaltySnapshot.docs.isNotEmpty) {
        penaltyId = penaltySnapshot.docs.first.id;
      }

      await FirebaseFirestore.instance.collection('lending_requests').doc(lendingRequestId).update({
        'isReturnRequest': true,
        'returnRequestStatus': 'pending',
        'returnTimestamp': Timestamp.now(),
        if (penaltyId != null) 'penaltyId': penaltyId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return request sent successfully.')),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  int _getSortPriority(Map<String, dynamic> data) {
    final isReturnRequested = data['isReturnRequest'] == true;
    final isRejected = data['returnRequestStatus'] == 'rejected';
    if (!isReturnRequested) return 0;
    if (isReturnRequested && !isRejected) return 1;
    if (isRejected) return 2;
    return 3;
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
            "My Borrowed Books",
            style: TextStyle(
              color: Color(0xFF00253A),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('alerts')
                  .where('userId', isEqualTo: user?.uid)
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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lending_requests')
              .where('userId', isEqualTo: user?.uid)
              .where('status', isEqualTo: 'approved')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final requests = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isReturned'] != true;
            }).toList();

            if (requests.isEmpty) {
              return const Center(
                child: Text(
                  '📚 No borrowed books found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            requests.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              return _getSortPriority(aData).compareTo(_getSortPriority(bData));
            });

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final data = requests[index].data() as Map<String, dynamic>;
                final lendingRequestId = requests[index].id;
                final bookId = data['bookId'];
                final isReturnRequested = data['isReturnRequest'] == true;
                final returnStatus = data['returnRequestStatus'];
                final canRequestReturn = !isReturnRequested || returnStatus == 'rejected';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();

                    final bookData = snapshot.data!.data() as Map<String, dynamic>;
                    final title = bookData['title'] ?? 'Untitled';
                    final author = bookData['author'] ?? 'Unknown';
                    final imageUrl = bookData['imageUrl'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 60,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.menu_book, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00253A),
                          ),
                        ),
                        subtitle: Text(
                          'by $author',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        trailing: ElevatedButton(
                          onPressed: canRequestReturn
                              ? () => _sendReturnRequest(lendingRequestId, bookId)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canRequestReturn ? const Color(0xFF00253A) : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            !isReturnRequested
                                ? 'Return'
                                : returnStatus == 'pending'
                                ? 'Request Sent'
                                : returnStatus == 'rejected'
                                ? 'Retry Return'
                                : 'Returned',
                            style: const TextStyle(fontSize: 13),
                          ),
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
    );
  }
}
