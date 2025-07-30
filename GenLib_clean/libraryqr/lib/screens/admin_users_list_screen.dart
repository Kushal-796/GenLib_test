import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/screens/admin_users_borrowed_books_screen.dart';
import 'package:libraryqr/screens/admin_available_books_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/admin_app_drawer.dart';

class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});

  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _generateExcelStylePdf() async {
    final pdf = pw.Document();

    final lendingSnapshot = await FirebaseFirestore.instance
        .collection('lending_requests')
        .where('status', isEqualTo: 'approved')
        .orderBy('timestamp', descending: true)
        .get();

    final rows = <List<String>>[];
    int serial = 1;

    for (final doc in lendingSnapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final bookId = data['bookId'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final formattedDate = "${timestamp.day}/${timestamp.month}/${timestamp.year}";

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'Unknown';
      final userEmail = userData['email'] ?? 'No Email';

      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      final bookData = bookDoc.data() ?? {};
      final bookTitle = bookData['title'] ?? 'Unknown';
      final author = bookData['author'] ?? 'Unknown';

      final amount = (data['penaltyAmount'] ?? 0).toDouble();
      final isPaid = data['isPaid'] == true;
      final penalty = "${amount.toStringAsFixed(0)} (${isPaid ? 'Paid' : 'Unpaid'})";


      rows.add([
        serial.toString(),
        userName,
        userEmail,
        bookId,
        bookTitle,
        author,
        formattedDate,
        penalty,
      ]);

      serial++;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text("Library Lending & Penalty Report", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: [
              'S no',
              'User name',
              'User mail',
              'BookId',
              'Book name',
              'Author',
              'Borrowed date',
              'Penalty'
            ],
            data: rows,
            headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 10),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      format: PdfPageFormat.a4.landscape,
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<List<Widget>> _buildUserCards(Set<String> userIds) async {
    List<Widget> cards = [];

    for (final userId in userIds) {
      final userData = await _fetchUserData(userId);
      if (userData == null) continue;

      final name = (userData['name'] ?? '').toString();
      final email = (userData['email'] ?? '').toString();

      final matchesQuery = _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery) ||
          email.toLowerCase().contains(_searchQuery);

      if (matchesQuery) {
        cards.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.person, color: Colors.blueGrey),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(email),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUsersBorrowedBooksScreen(
                      userId: userId,
                      userName: name,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
    return cards;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dad-style AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Users List",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00253A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Search by name or email",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase().trim();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // User List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('lending_requests')
                        .where('status', isEqualTo: 'approved')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final requests = snapshot.data!.docs;
                      final Set<String> uniqueUserIds = requests.map((doc) => doc['userId'] as String).toSet();

                      return FutureBuilder<List<Widget>>(
                        future: _buildUserCards(uniqueUserIds),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final cards = snapshot.data!;
                          return cards.isEmpty
                              ? const Center(child: Text("No matching users found."))
                              : ListView(children: cards);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF00253A),
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text(
            "Download PDF",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          onPressed: () async {
            await _generateExcelStylePdf();
          },
        ),
      ),
    );
  }
}
