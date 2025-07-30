import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/admin_app_drawer.dart';
import 'admin_available_books_screen.dart';

class AdminPenaltyScreen extends StatelessWidget {
  const AdminPenaltyScreen({super.key});

  Future<void> markAsPaid(String docId) async {
    await FirebaseFirestore.instance.collection('penalties').doc(docId).update({
      'isPaid': true,
    });
  }

  Future<Map<String, String>> getBookAndUserInfo(String bookId, String userId) async {
    final bookSnapshot = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final bookTitle = bookSnapshot.exists ? bookSnapshot['title'] ?? 'Unknown Title' : 'Unknown Title';
    final userName = userSnapshot.exists ? userSnapshot['name'] ?? 'Unknown User' : 'Unknown User';

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
                          .collection('penalties')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(child: Text("✅ No penalties found."));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final bookId = data['bookId'] ?? '';
                            final userId = data['userId'] ?? '';
                            final timestamp = data['timestamp'] as Timestamp;
                            final isPaid = data['isPaid'] ?? false;
                            final penaltyAmount = data['penaltyAmount'] ?? 0;
                            final dateTime = timestamp.toDate();
                            final formattedTime =
                                '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

                            return FutureBuilder<Map<String, String>>(
                              future: getBookAndUserInfo(bookId, userId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: LinearProgressIndicator(),
                                  );
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
                                              ElevatedButton(
                                                onPressed: () async {
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
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
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
