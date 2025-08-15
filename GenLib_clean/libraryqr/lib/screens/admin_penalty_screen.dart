import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/admin_app_drawer.dart';
import '../screens/admin_available_books_screen.dart';

class AdminPenaltyScreen extends StatelessWidget {
  const AdminPenaltyScreen({super.key});

  Future<void> markAsPaid(String docId) async {
    // We are updating a document in 'lending_requests' now, not 'penalties'
    debugPrint('Attempting to mark penalty $docId in lending_requests as paid...');
    try {
      await FirebaseFirestore.instance.collection('lending_requests').doc(docId).update({
        'isPaid': true,
      });
      debugPrint('Penalty $docId marked as paid (request sent).');
    } catch (e) {
      debugPrint('Error marking penalty as paid: $e');
      // You might want to show a SnackBar here too for errors
    }
  }

  Future<Map<String, String>> getBookAndUserInfo(String bookId, String userId) async {
    debugPrint('Fetching details for bookId: $bookId, userId: $userId');
    final bookSnapshot = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final bookTitle = bookSnapshot.exists ? bookSnapshot['title'] ?? 'Unknown Title' : 'Unknown Title';
    final userName = userSnapshot.exists ? userSnapshot['name'] ?? 'Unknown User' : 'Unknown User';

    debugPrint('Fetched bookTitle: $bookTitle, userName: $userName');
    return {
      'bookTitle': bookTitle,
      'userName': userName,
    };
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
        drawer: const AdminAppDrawer(),
        body: SafeArea(
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Penalty',
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
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('lending_requests')
                          .where('penaltyAmount', isGreaterThan: 0)
                          .where('isPaid', isEqualTo: false)
                          .orderBy('penaltyAmount', descending: true)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          debugPrint('StreamBuilder: Connection waiting...');
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          debugPrint('StreamBuilder: Error - ${snapshot.error}');
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }

                        final docs = snapshot.data?.docs ?? [];
                        debugPrint('StreamBuilder: Received ${docs.length} penalty documents (from lending_requests).');

                        if (docs.isEmpty) {
                          return const Center(child: Text("✅ No unpaid penalties found."));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            debugPrint('Processing lending_request docId: ${doc.id}, data: $data');

                            final bookId = data['bookId'] ?? '';
                            final userId = data['userId'] ?? '';
                            final timestamp = data['timestamp'] as Timestamp?;
                            final isPaid = data['isPaid'] ?? false;
                            final penaltyAmount = data['penaltyAmount'] ?? 0;
                            final isReturnRequest = data['isReturnRequest'] ?? false; // <-- Get isReturnRequest

                            final formattedTime = (timestamp != null)
                                ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                                : 'N/A';

                            if (bookId.isEmpty || userId.isEmpty) {
                              debugPrint('Skipping list item due to empty bookId or userId for docId: ${doc.id}');
                              return const SizedBox.shrink();
                            }

                            return FutureBuilder<Map<String, String>>(
                              future: getBookAndUserInfo(bookId, userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  debugPrint('FutureBuilder for ${doc.id}: Connection waiting...');
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: LinearProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  debugPrint('FutureBuilder for ${doc.id}: Error - ${snapshot.error}');
                                  return Center(child: Text('Error loading details for ${doc.id}'));
                                }

                                if (!snapshot.hasData) {
                                  debugPrint('FutureBuilder for ${doc.id}: No data received.');
                                  return const SizedBox.shrink();
                                }

                                final bookTitle = snapshot.data!['bookTitle']!;
                                final userName = snapshot.data!['userName']!;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.warning, color: Colors.orange),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Book: $bookTitle",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Color(0xFF00253A),
                                                  )),
                                              const SizedBox(height: 6),
                                              Text("User: $userName"),
                                              const SizedBox(height: 6),
                                              Text("Issued: $formattedTime"),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("₹$penaltyAmount",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 8),
                                            if (isPaid)
                                              const Chip(
                                                label: Text("Paid",
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold)),
                                                backgroundColor: Color(0xFFDFFFE0),
                                              )
                                            else if (penaltyAmount == 0)
                                              const Chip(
                                                label: Text("No Fine",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight.bold)),
                                                backgroundColor: Color(0xFFE0E0E0),
                                              )
                                            else
                                            // Conditional rendering and onPressed for the button
                                              ElevatedButton(
                                                // Only enable if isReturnRequest is true
                                                onPressed: isReturnRequest
                                                    ? () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Confirm Payment'),
                                                      content: const Text(
                                                          'Are you sure you want to mark this penalty as paid?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(context, false),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(context, true),
                                                          style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.green),
                                                          child: const Text('Confirm'),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm == true) {
                                                    await markAsPaid(doc.id);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                            content: Text('Penalty marked as paid!')),
                                                      );
                                                    }
                                                  }
                                                }
                                                    : null, // Set onPressed to null to disable the button

                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isReturnRequest // Change color based on enabled state
                                                      ? Colors.green
                                                      : Colors.grey, // Grey out if disabled
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 14, vertical: 6),
                                                  textStyle: const TextStyle(fontSize: 13),
                                                ),
                                                child: const Text("Mark Paid"),
                                              ),
                                          ],
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
