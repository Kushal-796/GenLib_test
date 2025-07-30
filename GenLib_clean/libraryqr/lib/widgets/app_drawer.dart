import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/screens/user_explore_screen.dart';

import '../screens/book_list_screen.dart';
import '../screens/borrowed_books_screen.dart';
import '../screens/history_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/penalty_screen.dart';
import '../screens/user_home_screen.dart';
import '../screens/user_profile.dart';
import '../screens/user_wishlist_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const AppDrawer({super.key, required this.onToggleTheme});

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User';
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists ? (doc.data()?['name'] ?? 'User') : 'User';
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF00253A),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF00253A),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'user@example.com';

    return Drawer(
      backgroundColor: const Color(0xFFF3FAF8),
      child: Column(
        children: [
          const SizedBox(height: 40), // Top spacing
          FutureBuilder<String>(
            future: getUserName(),
            builder: (context, snapshot) {
              final userName = snapshot.data ?? 'User';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF00253A),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00253A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Drawer menu items
          Expanded(
            child: ListView(
              children: [
                _drawerItem(
                  context: context,
                  icon: Icons.home,
                  label: 'Home',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => UserHomeScreen()),
                  ),
                ),
                _drawerItem(
                  context: context,
                  icon: Icons.search,
                  label: 'Explore',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => UserExploreScreen()),
                  ),
                ),
                _drawerItem(
                  context: context,
                  icon: Icons.book,
                  label: 'Available Books',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BookListScreen()),
                  ),
                ),
                _drawerItem(
                  context: context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => QRScannerScreen()),
                  ),
                ),
                _drawerItem(
                  context: context,
                  icon: Icons.bookmark,
                  label: 'My Borrowed Books',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BorrowedBooksScreen()),
                  ),
                ),
                // _drawerItem(
                //   context: context,
                //   icon: Icons.notifications,
                //   label: 'Alerts',
                //   onTap: () => Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(builder: (_) => AlertsScreen()),
                //   ),
                // ),
                _drawerItem(
                  context: context,
                  icon: Icons.attach_money,
                  label: 'Penalty',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => PenaltyScreen()),
                  ),
                ),
                _drawerItem(
                  context: context,
                  icon: Icons.history,
                  label: 'History',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryScreen(onToggleTheme: () {  },)),
                  ),
                ),
                _drawerItem(
                  context: context,
                  icon: Icons.favorite,
                  label: 'Wishlist',
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserWishlistScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(thickness: 1, color: Colors.black26),

          // Logout section (flat style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00253A),
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(color: Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
