import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/screens/admin_available_books_screen.dart';
import 'package:libraryqr/screens/admin_pending_requests.dart';
import 'package:libraryqr/screens/admin_processed_requests.dart';
import 'package:libraryqr/screens/admin_return_requests_screen.dart';
import 'package:libraryqr/screens/admin_users_list_screen.dart';
import 'package:libraryqr/screens/admin_penalty_screen.dart';
import 'package:libraryqr/screens/admin_manage_books.dart';

class AdminAppDrawer extends StatelessWidget {
  const AdminAppDrawer({super.key});

  void _navigateToScreen(BuildContext context, int index) {
    Widget targetScreen;

    switch (index) {
      case 0:
        targetScreen = const AdminAvailableBooksScreen();
        break;
      case 1:
        targetScreen = const AdminPendingRequests();
        break;
      case 2:
        targetScreen = const AdminProcessedRequests();
        break;
      case 3:
        targetScreen = const AdminReturnRequestsScreen();
        break;
      case 4:
        targetScreen = const AdminUsersListScreen();
        break;
      case 5:
        targetScreen = const AdminPenaltyScreen();
        break;
      case 6:
        targetScreen = const AdminManageBooksScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00253A)),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF00253A),
          ),
        ),
        onTap: () => _navigateToScreen(context, index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'admin@example.com';

    return Drawer(
      backgroundColor: const Color(0xFFF3FAF8),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF00253A),
                  child: Icon(Icons.admin_panel_settings, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(
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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(context: context, icon: Icons.library_books, label: 'Available Books', index: 0),
                _drawerItem(context: context, icon: Icons.hourglass_empty, label: 'Pending Requests', index: 1),
                _drawerItem(context: context, icon: Icons.check_circle_outline, label: 'Processed Requests', index: 2),
                _drawerItem(context: context, icon: Icons.assignment_return, label: 'Return Requests', index: 3),
                _drawerItem(context: context, icon: Icons.group, label: 'Users', index: 4),
                _drawerItem(context: context, icon: Icons.attach_money, label: 'Penalty', index: 5),
                _drawerItem(context: context, icon: Icons.manage_search, label: 'Manage Books', index: 6),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.black26),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00253A))),
                    content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.black87)),
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
