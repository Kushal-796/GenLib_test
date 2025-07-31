// // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // import 'package:firebase_storage/firebase_storage.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:image_picker/image_picker.dart';
// // // // // import 'dart:io';
// // // // //
// // // // // import '../widgets/admin_app_drawer.dart';
// // // // // import 'package:libraryqr/screens/admin_available_books_screen.dart';
// // // // //
// // // // // class AdminManageBooksScreen extends StatefulWidget {
// // // // //   const AdminManageBooksScreen({super.key});
// // // // //
// // // // //   @override
// // // // //   State<AdminManageBooksScreen> createState() => _AdminManageBooksScreenState();
// // // // // }
// // // // //
// // // // // class _AdminManageBooksScreenState extends State<AdminManageBooksScreen> {
// // // // //   final List<String> genres = const [
// // // // //     'Technology', 'Story Books', 'Comics', 'Fiction', 'Sci-Fi',
// // // // //     'Science', 'Mathematics', 'Literature', 'Spiritual',
// // // // //     'General Knowledge', 'Biography'
// // // // //   ];
// // // // //
// // // // //   Future<void> _addBookDialog(BuildContext context) async {
// // // // //     final bookIdController = TextEditingController();
// // // // //     final titleController = TextEditingController();
// // // // //     final authorController = TextEditingController();
// // // // //     final countController = TextEditingController();
// // // // //     String? selectedGenre;
// // // // //     XFile? pickedImage;
// // // // //
// // // // //     await showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: const Text("Add New Book"),
// // // // //         content: StatefulBuilder(
// // // // //           builder: (context, setState) => SingleChildScrollView(
// // // // //             child: Column(
// // // // //               mainAxisSize: MainAxisSize.min,
// // // // //               children: [
// // // // //                 TextField(controller: bookIdController, decoration: const InputDecoration(labelText: "Book ID")),
// // // // //                 TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
// // // // //                 TextField(controller: authorController, decoration: const InputDecoration(labelText: "Author")),
// // // // //                 TextField(
// // // // //                   controller: countController,
// // // // //                   decoration: const InputDecoration(labelText: "Number of Copies"),
// // // // //                   keyboardType: TextInputType.number,
// // // // //                 ),
// // // // //                 const SizedBox(height: 12),
// // // // //                 DropdownButtonFormField<String>(
// // // // //                   decoration: const InputDecoration(labelText: "Genre"),
// // // // //                   value: selectedGenre,
// // // // //                   onChanged: (value) => setState(() => selectedGenre = value),
// // // // //                   items: genres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))).toList(),
// // // // //                 ),
// // // // //                 const SizedBox(height: 12),
// // // // //                 ElevatedButton.icon(
// // // // //                   onPressed: () async {
// // // // //                     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
// // // // //                     if (picked != null) setState(() => pickedImage = picked);
// // // // //                   },
// // // // //                   icon: const Icon(Icons.photo),
// // // // //                   label: Text(pickedImage == null ? "Upload Cover Photo" : "Change Photo"),
// // // // //                 ),
// // // // //                 if (pickedImage != null) const Text("✅ Image selected", style: TextStyle(color: Colors.green)),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //         actions: [
// // // // //           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
// // // // //           ElevatedButton(
// // // // //             onPressed: () async {
// // // // //               final bookId = bookIdController.text.trim();
// // // // //               final title = titleController.text.trim();
// // // // //               final author = authorController.text.trim();
// // // // //               final count = int.tryParse(countController.text.trim());
// // // // //
// // // // //               if (bookId.isNotEmpty && title.isNotEmpty && author.isNotEmpty && count != null && selectedGenre != null && pickedImage != null) {
// // // // //                 try {
// // // // //                   final ref = FirebaseStorage.instance
// // // // //                       .ref()
// // // // //                       .child('book_covers/$bookId.jpg');
// // // // //                   await ref.putFile(File(pickedImage!.path));
// // // // //                   final imageUrl = await ref.getDownloadURL();
// // // // //
// // // // //                   await FirebaseFirestore.instance.collection('books').doc(bookId).set({
// // // // //                     'bookId': bookId,
// // // // //                     'title': title,
// // // // //                     'author': author,
// // // // //                     'count': count,
// // // // //                     'genre': selectedGenre,
// // // // //                     'isAvailable': true,
// // // // //                     'imageUrl': imageUrl,
// // // // //                   });
// // // // //
// // // // //                   if (mounted) {
// // // // //                     Navigator.pop(context);
// // // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // // //                       const SnackBar(content: Text("📚 Book added with cover photo!")),
// // // // //                     );
// // // // //                   }
// // // // //                 } catch (e) {
// // // // //                   if (mounted) {
// // // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // // //                       SnackBar(content: Text("❌ Error: $e")),
// // // // //                     );
// // // // //                   }
// // // // //                 }
// // // // //               } else {
// // // // //                 ScaffoldMessenger.of(context).showSnackBar(
// // // // //                   const SnackBar(content: Text("❗Fill all fields and pick an image")),
// // // // //                 );
// // // // //               }
// // // // //             },
// // // // //             child: const Text("Add Book"),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Future<void> _addExistingBookDialog(BuildContext context) async {
// // // // //     final bookIdController = TextEditingController();
// // // // //     final countController = TextEditingController();
// // // // //
// // // // //     await showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: const Text("Add Existing Book Copies"),
// // // // //         content: Column(
// // // // //           mainAxisSize: MainAxisSize.min,
// // // // //           children: [
// // // // //             TextField(
// // // // //               controller: bookIdController,
// // // // //               decoration: const InputDecoration(labelText: "Enter Book ID"),
// // // // //             ),
// // // // //             TextField(
// // // // //               controller: countController,
// // // // //               decoration: const InputDecoration(labelText: "No. of Copies to Add"),
// // // // //               keyboardType: TextInputType.number,
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         actions: [
// // // // //           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
// // // // //           ElevatedButton(
// // // // //             onPressed: () async {
// // // // //               final bookId = bookIdController.text.trim();
// // // // //               final addCount = int.tryParse(countController.text.trim());
// // // // //
// // // // //               if (bookId.isNotEmpty && addCount != null && addCount > 0) {
// // // // //                 final bookRef = FirebaseFirestore.instance.collection('books').doc(bookId);
// // // // //                 final bookDoc = await bookRef.get();
// // // // //
// // // // //                 if (bookDoc.exists) {
// // // // //                   final currentCount = bookDoc.data()?['count'] ?? 0;
// // // // //
// // // // //                   await bookRef.update({
// // // // //                     'count': currentCount + addCount,
// // // // //                     'isAvailable': true,
// // // // //                   });
// // // // //
// // // // //                   if (mounted) {
// // // // //                     Navigator.pop(context);
// // // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // // //                       SnackBar(content: Text("📦 Added $addCount copies to '$bookId'")),
// // // // //                     );
// // // // //                   }
// // // // //                 } else {
// // // // //                   Navigator.pop(context);
// // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // //                     const SnackBar(content: Text("❌ Book not found")),
// // // // //                   );
// // // // //                 }
// // // // //               } else {
// // // // //                 ScaffoldMessenger.of(context).showSnackBar(
// // // // //                   const SnackBar(content: Text("⚠️ Enter valid Book ID and count")),
// // // // //                 );
// // // // //               }
// // // // //             },
// // // // //             child: const Text("Add Copies"),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Future<void> _deleteBookDialog(BuildContext context) async {
// // // // //     final bookIdController = TextEditingController();
// // // // //
// // // // //     await showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: const Text("Delete Book"),
// // // // //         content: TextField(
// // // // //           controller: bookIdController,
// // // // //           decoration: const InputDecoration(labelText: "Enter Book ID"),
// // // // //         ),
// // // // //         actions: [
// // // // //           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
// // // // //           ElevatedButton(
// // // // //             onPressed: () async {
// // // // //               final bookId = bookIdController.text.trim();
// // // // //
// // // // //               if (bookId.isNotEmpty) {
// // // // //                 final doc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
// // // // //                 if (doc.exists) {
// // // // //                   await doc.reference.delete();
// // // // //                   if (mounted) {
// // // // //                     Navigator.pop(context);
// // // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // // //                       const SnackBar(content: Text("🗑️ Book deleted successfully")),
// // // // //                     );
// // // // //                   }
// // // // //                 } else {
// // // // //                   Navigator.pop(context);
// // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // //                     const SnackBar(content: Text("❌ Book not found")),
// // // // //                   );
// // // // //                 }
// // // // //               }
// // // // //             },
// // // // //             child: const Text("Delete"),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return WillPopScope(
// // // // //       onWillPop: () async {
// // // // //         Navigator.of(context).pushReplacement(
// // // // //           MaterialPageRoute(builder: (_) => const AdminAvailableBooksScreen()),
// // // // //         );
// // // // //         return false;
// // // // //       },
// // // // //       child: Scaffold(
// // // // //         backgroundColor: const Color(0xFFF3FAF8),
// // // // //         drawer: const AdminAppDrawer(),
// // // // //         body: SafeArea(
// // // // //           child: Builder(
// // // // //             builder: (context) => Padding(
// // // // //               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
// // // // //               child: Column(
// // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                 children: [
// // // // //                   // Dad-style AppBar
// // // // //                   Row(
// // // // //                     children: [
// // // // //                       GestureDetector(
// // // // //                         onTap: () => Scaffold.of(context).openDrawer(),
// // // // //                         child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
// // // // //                       ),
// // // // //                       const SizedBox(width: 12),
// // // // //                       const Text(
// // // // //                         'Manage Books',
// // // // //                         style: TextStyle(
// // // // //                           fontSize: 26,
// // // // //                           fontWeight: FontWeight.w600,
// // // // //                           color: Color(0xFF00253A),
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                   const SizedBox(height: 24),
// // // // //                   Center(
// // // // //                     child: Column(
// // // // //                       children: [
// // // // //                         SizedBox(
// // // // //                           width: double.infinity,
// // // // //                           child: ElevatedButton.icon(
// // // // //                             onPressed: () => _addBookDialog(context),
// // // // //                             icon: const Icon(Icons.add, color: Colors.white),
// // // // //                             label: const Text("Add Book", style: TextStyle(color: Colors.white)),
// // // // //                             style: ElevatedButton.styleFrom(
// // // // //                               backgroundColor: Colors.green[700],
// // // // //                               elevation: 0,
// // // // //                               padding: const EdgeInsets.symmetric(vertical: 16),
// // // // //                               shape: RoundedRectangleBorder(
// // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // //                               ),
// // // // //                               textStyle: const TextStyle(
// // // // //                                 fontSize: 15,
// // // // //                                 fontWeight: FontWeight.w500,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                         const SizedBox(height: 16),
// // // // //                         SizedBox(
// // // // //                           width: double.infinity,
// // // // //                           child: ElevatedButton.icon(
// // // // //                             onPressed: () => _deleteBookDialog(context),
// // // // //                             icon: const Icon(Icons.delete, color: Colors.white),
// // // // //                             label: const Text("Delete Book", style: TextStyle(color: Colors.white)),
// // // // //                             style: ElevatedButton.styleFrom(
// // // // //                               backgroundColor: Colors.red[600],
// // // // //                               elevation: 0,
// // // // //                               padding: const EdgeInsets.symmetric(vertical: 16),
// // // // //                               shape: RoundedRectangleBorder(
// // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // //                               ),
// // // // //                               textStyle: const TextStyle(
// // // // //                                 fontSize: 15,
// // // // //                                 fontWeight: FontWeight.w500,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                         const SizedBox(height: 16),
// // // // //                         SizedBox(
// // // // //                           width: double.infinity,
// // // // //                           child: ElevatedButton.icon(
// // // // //                             onPressed: () => _addExistingBookDialog(context),
// // // // //                             icon: const Icon(Icons.library_add, color: Colors.white),
// // // // //                             label: const Text("Add Existing Book", style: TextStyle(color: Colors.white)),
// // // // //                             style: ElevatedButton.styleFrom(
// // // // //                               backgroundColor: Colors.blue[700],
// // // // //                               elevation: 0,
// // // // //                               padding: const EdgeInsets.symmetric(vertical: 16),
// // // // //                               shape: RoundedRectangleBorder(
// // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // //                               ),
// // // // //                               textStyle: const TextStyle(
// // // // //                                 fontSize: 15,
// // // // //                                 fontWeight: FontWeight.w500,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   )
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/admin_app_drawer.dart';
import 'package:libraryqr/screens/admin_available_books_screen.dart';

class AdminManageBooksScreen extends StatefulWidget {
  const AdminManageBooksScreen({super.key});

  @override
  State<AdminManageBooksScreen> createState() => _AdminManageBooksScreenState();
}

class _AdminManageBooksScreenState extends State<AdminManageBooksScreen> {
  final List<String> genres = const [
    'Technology', 'Story Books', 'Comics', 'Fiction', 'Sci-Fi',
    'Science', 'Mathematics', 'Literature', 'Spiritual',
    'General Knowledge', 'Biography'
  ];

  // --- UPDATED: Function now fetches only the book's main description ---
  Future<String> _fetchBookDescription(String title, String author) async {
    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=intitle:"$title"+inauthor:"$author"&maxResults=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0 && data['items'][0]['volumeInfo'] != null) {
          final volumeInfo = data['items'][0]['volumeInfo'];

          final description = volumeInfo['description'] ?? 'No description available.';

          // Format and return only the main description
          return description;
        }
      }
      return 'No description found.';
    } catch (e) {
      return 'Error fetching description: $e';
    }
  }

  // --- NEW: Helper function to show specific validation errors ---
  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❗ $message'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }


  Future<void> _addBookDialog(BuildContext context) async {
    final bookIdController = TextEditingController();
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final countController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedGenre;
    XFile? pickedImage;
    bool isFetchingDescription = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Book"),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: bookIdController, decoration: const InputDecoration(labelText: "Book ID")),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: authorController, decoration: const InputDecoration(labelText: "Author")),
                TextField(
                  controller: countController,
                  decoration: const InputDecoration(labelText: "Number of Copies"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Genre"),
                  value: selectedGenre,
                  onChanged: (value) => setState(() => selectedGenre = value),
                  items: genres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 8,
                ),
                const SizedBox(height: 12),
                isFetchingDescription
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && authorController.text.isNotEmpty) {
                      setState(() => isFetchingDescription = true);
                      final desc = await _fetchBookDescription(
                          titleController.text, authorController.text);
                      descriptionController.text = desc;
                      setState(() => isFetchingDescription = false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a title and author first.")),
                      );
                    }
                  },
                  icon: const Icon(Icons.find_in_page),
                  label: const Text("Fetch Description"),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picked != null) setState(() => pickedImage = picked);
                  },
                  icon: const Icon(Icons.photo),
                  label: Text(pickedImage == null ? "Upload Cover Photo" : "Change Photo"),
                ),
                if (pickedImage != null) const Text("✅ Image selected", style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final bookId = bookIdController.text.trim();
              final title = titleController.text.trim();
              final author = authorController.text.trim();
              final count = int.tryParse(countController.text.trim());
              final description = descriptionController.text.trim();

              // --- UPDATED: Switched to specific, sequential validation ---
              if (bookId.isEmpty) {
                _showValidationError(context, "Please enter a Book ID.");
                return;
              }
              if (title.isEmpty) {
                _showValidationError(context, "Please enter a Title.");
                return;
              }
              if (author.isEmpty) {
                _showValidationError(context, "Please enter an Author.");
                return;
              }
              if (count == null || count <= 0) {
                _showValidationError(context, "Please enter a valid number of copies.");
                return;
              }
              if (selectedGenre == null) {
                _showValidationError(context, "Please select a Genre.");
                return;
              }
              if (description.isEmpty) {
                _showValidationError(context, "Please add a Description for the book.");
                return;
              }
              if (pickedImage == null) {
                _showValidationError(context, "Please upload a cover photo.");
                return;
              }

              // If all checks pass, proceed with adding the book
              try {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('book_covers/$bookId.jpg');

                // --- CORRECTED: Reverted to the original, working putFile method ---
                await ref.putFile(File(pickedImage!.path));

                final imageUrl = await ref.getDownloadURL();

                await FirebaseFirestore.instance.collection('books').doc(bookId).set({
                  'bookId': bookId,
                  'title': title,
                  'author': author,
                  'count': count,
                  'genre': selectedGenre,
                  'isAvailable': true,
                  'imageUrl': imageUrl,
                  'description': description,
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("📚 Book added with cover photo!")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  _showValidationError(context, "Error adding book: $e");
                }
              }
            },
            child: const Text("Add Book"),
          ),
        ],
      ),
    );
  }

  Future<void> _addExistingBookDialog(BuildContext context) async {
    final bookIdController = TextEditingController();
    final countController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Existing Book Copies"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bookIdController,
              decoration: const InputDecoration(labelText: "Enter Book ID"),
            ),
            TextField(
              controller: countController,
              decoration: const InputDecoration(labelText: "No. of Copies to Add"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final bookId = bookIdController.text.trim();
              final addCount = int.tryParse(countController.text.trim());

              if (bookId.isNotEmpty && addCount != null && addCount > 0) {
                final bookRef = FirebaseFirestore.instance.collection('books').doc(bookId);
                final bookDoc = await bookRef.get();

                if (bookDoc.exists) {
                  final currentCount = bookDoc.data()?['count'] ?? 0;

                  await bookRef.update({
                    'count': currentCount + addCount,
                    'isAvailable': true,
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("📦 Added $addCount copies to '$bookId'")),
                    );
                  }
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Book not found")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Enter valid Book ID and count")),
                );
              }
            },
            child: const Text("Add Copies"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBookDialog(BuildContext context) async {
    final bookIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: TextField(
          controller: bookIdController,
          decoration: const InputDecoration(labelText: "Enter Book ID"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final bookId = bookIdController.text.trim();

              if (bookId.isNotEmpty) {
                final doc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
                if (doc.exists) {
                  await doc.reference.delete();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🗑️ Book deleted successfully")),
                    );
                  }
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Book not found")),
                  );
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
                  // Dad-style AppBar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Manage Books',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00253A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _addBookDialog(context),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Add Book", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _deleteBookDialog(context),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text("Delete Book", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _addExistingBookDialog(context),
                            icon: const Icon(Icons.library_add, color: Colors.white),
                            label: const Text("Add Existing Book", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
