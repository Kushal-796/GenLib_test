import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/widgets/admin_app_drawer.dart';
import 'admin_available_books_screen.dart'; // ✅ For back navigation

class AdminReturnRequestsScreen extends StatelessWidget {
  const AdminReturnRequestsScreen({super.key});

  Future<Map<String, dynamic>> _fetchDetails(
      String userId, String bookId, Map<String, dynamic> requestData) async {
    String userName = 'Unknown';
    String bookTitle = 'Unknown';
    bool canApprove = true;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        userName = userDoc.data()?['name'] ?? 'Unknown';
      }

      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        bookTitle = bookDoc.data()?['title'] ?? 'Unknown';
      }

      final isPaid = requestData['isPaid'] == true;
      final amount = (requestData['penaltyAmount'] ?? 0).toDouble();
      if (!isPaid && amount > 0) canApprove = false;

    } catch (e) {
      debugPrint("🔥 Error in _fetchDetails: $e");
    }

    return {
      'userName': userName,
      'bookTitle': bookTitle,
      'canApprove': canApprove,
    };
  }

  Future<void> _processReturnRequest(
      BuildContext context,
      String lendingRequestId,
      String bookId,
      bool approve) async {
    final firestore = FirebaseFirestore.instance;
    final lendingRef = firestore.collection('lending_requests').doc(lendingRequestId);
    final bookRef = firestore.collection('books').doc(bookId);

    try {
      if (approve) {
        await firestore.runTransaction((txn) async {
          final bookSnap = await txn.get(bookRef);
          final requestSnap = await txn.get(lendingRef);
          if (!bookSnap.exists || !requestSnap.exists) throw Exception('Book or request not found');

          final currentCount = bookSnap.get('count') ?? 0;
          final userId = requestSnap.get('userId');
          final now = Timestamp.now();

          txn.update(bookRef, {
            'count': currentCount + 1,
            'isAvailable': true,
          });

          txn.update(lendingRef, {
            'isReturned': true,
            'isReturnRequest': false,
            'returnRequestStatus': 'approved',
            'processedAt': now,
            'isPaid': true,
          });

          final userRef = firestore.collection('users').doc(userId);
          final userSnap = await txn.get(userRef);
          if (userSnap.exists) {
            int currentNob = userSnap.data()?['nob'] ?? 0;
            if (currentNob > 0) {
              txn.update(userRef, {'nob': currentNob - 1});
            }
          }

          final bookTitle = bookSnap.get('title') ?? 'a book';

          await firestore.collection('alerts').add({
            'userId': userId,
            'bookId': bookId,
            'isRead': false,
            'timestamp': now,
            'message': '✅ Your return request for "$bookTitle" has been approved!',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Return approved ✅")),
        );
      } else {
        final requestSnap = await lendingRef.get();
        final userId = requestSnap.get('userId');
        final bookSnap = await bookRef.get();
        final bookTitle = bookSnap.get('title') ?? 'a book';
        final now = Timestamp.now();

        await lendingRef.update({
          'isReturnRequest': false,
          'returnRequestStatus': 'rejected',
          'processedAt': now,
        });

        await firestore.collection('alerts').add({
          'userId': userId,
          'bookId': bookId,
          'isRead': false,
          'timestamp': now,
          'message': '❌ Your return request for "$bookTitle" was rejected.',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Return request rejected ❌")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error processing return: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
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
        drawer: const AdminAppDrawer(),
        body: SafeArea(
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dad’s AppBar style
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
                          "Return Requests",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00253A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Requests List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('lending_requests')
                        .where('isReturnRequest', isEqualTo: true)
                        .where('returnRequestStatus', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No return requests."));
                      }

                      final requests = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final doc = requests[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final requestId = doc.id;
                          final bookId = data['bookId'];
                          final userId = data['userId'];

                          return FutureBuilder<Map<String, dynamic>>(
                            future: _fetchDetails(userId, bookId, data),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const ListTile(title: Text("Loading..."));
                              }

                              final details = snapshot.data!;
                              final userName = details['userName'];
                              final bookTitle = details['bookTitle'];
                              final canApprove = details['canApprove'];

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  leading: const Icon(Icons.assignment_return, color: Colors.blueGrey),
                                  title: Text(
                                    'User: $userName',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Book: $bookTitle'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Tooltip(
                                        message: canApprove ? 'Approve return' : 'Blocked: unpaid penalty',
                                        child: IconButton(
                                          icon: Icon(Icons.check,
                                              color: canApprove ? Colors.green : Colors.grey),
                                          onPressed: canApprove
                                              ? () => _processReturnRequest(
                                              context, requestId, bookId, true)
                                              : null,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _processReturnRequest(
                                            context, requestId, bookId, false),
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
    );
  }
}
