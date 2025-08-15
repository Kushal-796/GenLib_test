import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/admin_app_drawer.dart';
import 'admin_available_books_screen.dart';


class AdminPendingRequests extends StatefulWidget {
  const AdminPendingRequests({super.key});

  @override
  State<AdminPendingRequests> createState() => _AdminPendingRequestsState();
}

class _AdminPendingRequestsState extends State<AdminPendingRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _refreshData() async {
    // This is useful for setState to rebuild the StreamBuilder
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  Future<Map<String, String>> _getBookTitleAndUserName(String bookId, String userId) async {
    String bookTitle = 'Unknown Book';
    String userName = 'Unknown User';

    try {
      final bookSnap = await _firestore.collection('books').doc(bookId).get();
      if (bookSnap.exists) {
        bookTitle = bookSnap.data()?['title'] ?? bookTitle;
      }

      final userSnap = await _firestore.collection('users').doc(userId).get();
      if (userSnap.exists) {
        userName = userSnap.data()?['name'] ?? userName;
      }
    } catch (e) {
      debugPrint('Error fetching book/user info: $e');
    }

    return {
      'bookTitle': bookTitle,
      'userName': userName,
    };
  }

  Future<void> _updateRequest(String requestId, String bookId, String status) async {
    final requestRef = _firestore.collection('lending_requests').doc(requestId);
    final bookRef = _firestore.collection('books').doc(bookId);

    // Fetch book title outside the transaction for alert message if needed for both approve/reject paths
    // No, for approve path, it's fetched inside the transaction from bookSnap for consistency.
    // For reject path, it's fetched outside the transaction for simplicity.

    try {
      if (status == 'approved') {
        await _firestore.runTransaction((transaction) async {
          // --- ALL READS MUST BE AT THE BEGINNING OF THE TRANSACTION ---
          final bookSnap = await transaction.get(bookRef);
          final requestSnap = await transaction.get(requestRef); // Use requestRef
          // Ensure userId is read here if used by transaction operations later
          final userId = requestSnap.data()?['userId'];

          // Throw exception if critical documents are missing
          if (!bookSnap.exists) throw Exception("Book not found for approval.");
          if (!requestSnap.exists) throw Exception("Lending request not found for approval.");
          if (userId == null) throw Exception("User ID not found in request for approval.");


          final currentCount = bookSnap.get('count') ?? 0;
          final bookTitle = bookSnap.get('title') ?? 'Unknown Book'; // Get title inside transaction
          final now = Timestamp.now();

          if (currentCount > 0) {
            final newCount = currentCount - 1;

            // --- ALL WRITES MUST BE AFTER ALL READS ---
            transaction.update(bookRef, {
              'count': newCount,
              'isAvailable': newCount > 0,
            });

            transaction.update(requestRef, {
              'status': 'approved',
              'approvedAt': now,
              'penaltyAmount': 0,
              'isPaid': false,
              'isReturnRequest': false, // <--- ADDED THIS LINE FOR APPROVAL
            });

            // Add alert within the transaction using txn.set
            transaction.set(_firestore.collection('alerts').doc(), {
              'userId': userId,
              'bookId': bookId,
              'isRead': false,
              'timestamp': now,
              'message': '✅ Your request for "$bookTitle" has been approved!',
            });
          } else {
            // If book is unavailable, delete the request outside the transaction if not critical to atomicity
            // Or handle it within the transaction's else branch if appropriate.
            // For simplicity, deleting outside the transaction here.
            await requestRef.delete();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Book unavailable. Request deleted.')),
              );
            }
            return; // Exit as the request was deleted
          }
        });

        // After transaction commits
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request approved successfully')),
          );
        }
      } else {
        // --- REJECTED PATH (NOT A TRANSACTION) ---
        final requestSnap = await requestRef.get(); // Read request details
        final userId = requestSnap.data()?['userId'];
        final bookTitle = (await bookRef.get()).data()?['title'] ?? 'Unknown Book'; // Read book title

        if (!requestSnap.exists || userId == null) {
          throw Exception("Lending request or user ID not found for rejection.");
        }

        await requestRef.update({
          'status': status, // 'rejected'
        });

        // Review: Decrementing 'nob' on rejection is unusual if 'nob' means 'number of books currently borrowed'.
        // It typically only decrements on return. If this is intentional for your model, keep it.
        if (status == 'rejected') {
          final userRef = _firestore.collection('users').doc(userId);
          final userSnap = await userRef.get();
          if (userSnap.exists) {
            int currentNob = userSnap.data()?['nob'] ?? 0;
            if (currentNob > 0) {
              await userRef.update({'nob': currentNob - 1});
            }
          }
        }

        await _firestore.collection('alerts').add({
          'userId': userId,
          'bookId': bookId,
          'isRead': false,
          'timestamp': Timestamp.now(),
          'message': '❌ Your request for "$bookTitle" was rejected.',
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request ${status == 'approved' ? 'approved' : 'rejected'} successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating request: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')), // Use e.toString() for better error message
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminAvailableBooksScreen()),
          );
          return false;
        },
        child: Scaffold(
            backgroundColor: const Color(0xFFF3FAF8),
            drawer: AdminAppDrawer(),
            body: SafeArea(
              child: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dad's AppBar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Pending Requests',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00253A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshData,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('lending_requests')
                                .where('status', isEqualTo: 'pending')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }

                              final requests = snapshot.data?.docs ?? [];

                              if (requests.isEmpty) {
                                return const Center(child: Text('No pending requests.'));
                              }

                              return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final request = requests[index];
                                  final bookId = request['bookId'];
                                  final userId = request['userId'];
                                  final timestamp = request['timestamp'];

                                  final formattedDate = (timestamp != null && timestamp is Timestamp)
                                      ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                                      : 'Unknown';

                                  return FutureBuilder<Map<String, String>>(
                                    future: _getBookTitleAndUserName(bookId, userId),
                                    builder: (context, snapshot) {
                                      final bookTitle = snapshot.data?['bookTitle'] ?? 'Loading...';
                                      final userName = snapshot.data?['userName'] ?? 'Loading...';

                                      // This FutureBuilder for bookSnap inside the loop can be inefficient.
                                      // Consider optimizing this by getting isAvailable along with title/name
                                      // in _getBookTitleAndUserName, or filter the primary stream.
                                      return FutureBuilder<DocumentSnapshot>(
                                        future: _firestore.collection('books').doc(bookId).get(),
                                        builder: (context, bookSnap) {
                                          if (bookSnap.hasData && (bookSnap.data?.exists ?? false)) {
                                            final isAvailable = bookSnap.data?.get('isAvailable') ?? false;
                                            // If book is not available, we hide the request from this admin screen.
                                            // This assumes admins should only see requests for currently available books.
                                            if (!isAvailable) return const SizedBox.shrink(); // Use SizedBox.shrink() for efficiency

                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 10),
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
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                leading: const Icon(Icons.pending_actions, color: Colors.orange),
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
                                                    const SizedBox(height: 4),
                                                    Text("Requested on: $formattedDate"),
                                                  ],
                                                ),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.check, color: Colors.green),
                                                      onPressed: () => _updateRequest(request.id, bookId, 'approved'),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.red),
                                                      onPressed: () => _updateRequest(request.id, bookId, 'rejected'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            // If the book document doesn't exist or data is not available, hide the request
                                            debugPrint('Book document not found or data empty for bookId: $bookId. Hiding request: ${request.id}');
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
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
