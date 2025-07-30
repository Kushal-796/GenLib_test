import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/widgets/admin_app_drawer.dart';

class AdminAvailableBooksScreen extends StatefulWidget {
  const AdminAvailableBooksScreen({super.key});

  @override
  State<AdminAvailableBooksScreen> createState() => _AdminAvailableBooksScreenState();
}

class _AdminAvailableBooksScreenState extends State<AdminAvailableBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _showRestockDialog(BuildContext context, String bookId) async {
    final countController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Copies"),
        content: TextField(
          controller: countController,
          decoration: const InputDecoration(labelText: "Number of Copies to Add"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final added = int.tryParse(countController.text.trim());
              if (added != null && added > 0) {
                final docRef = FirebaseFirestore.instance.collection('books').doc(bookId);
                final snapshot = await docRef.get();
                final current = (snapshot.data()?['count'] ?? 0) as int;

                await docRef.update({
                  'count': current + added,
                  'isAvailable': true,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Copies added successfully")),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      drawer: AdminAppDrawer(
        // selectedIndex: 0, // this highlights "Available Books"
        // onItemSelected: (int index) {
        //   // optional: you can use Navigator.pushReplacement if needed
        // },
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Dad's AppBar"
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 32,
                        color: Color(0xFF00253A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Available Books',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00253A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),


                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by Title or Author",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                    });
                  },
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('books').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final books = snapshot.data?.docs ?? [];

                      final filteredBooks = books.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = (data['title'] ?? '').toString().toLowerCase();
                        final author = (data['author'] ?? '').toString().toLowerCase();
                        return title.contains(_searchQuery) || author.contains(_searchQuery);
                      }).toList();

                      if (filteredBooks.isEmpty) {
                        return const Center(child: Text('No matching books found.'));
                      }

                      return ListView.builder(
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final doc = filteredBooks[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'No Title';
                          final author = data['author'] ?? 'Unknown';
                          final count = data['count'] ?? 0;
                          final imageUrl = data['imageUrl'] ?? '';
                          final isAvailable = data['isAvailable'] == true;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00253A),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "by $author",
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          isAvailable ? "Available Copies: $count" : "Out of Stock",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (!isAvailable) ...[
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: () => _showRestockDialog(context, doc.id),
                                            icon: const Icon(Icons.add),
                                            label: const Text("Add Copies"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                              textStyle: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
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
      ),
    );
  }
}
