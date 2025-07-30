import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final Set<String> selectedIds = {};
  bool isSelectionMode = false;

  Stream<QuerySnapshot> _getAlertsStream() {
    return FirebaseFirestore.instance
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (selectedIds.contains(docId)) {
        selectedIds.remove(docId);
        if (selectedIds.isEmpty) isSelectionMode = false;
      } else {
        selectedIds.add(docId);
        isSelectionMode = true;
      }
    });
  }

  void _selectAll(List<QueryDocumentSnapshot> alerts) {
    setState(() {
      selectedIds.addAll(alerts.map((doc) => doc.id));
      isSelectionMode = true;
    });
  }

  Future<void> _deleteSelected() async {
    final batch = FirebaseFirestore.instance.batch();

    for (final id in selectedIds) {
      final ref = FirebaseFirestore.instance.collection('alerts').doc(id);
      batch.delete(ref);
    }

    await batch.commit();

    setState(() {
      selectedIds.clear();
      isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deleted selected alerts")),
    );
  }

  Future<void> _markAsRead(DocumentSnapshot doc) async {
    if (!(doc['isRead'] == true)) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF00253A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isSelectionMode ? "${selectedIds.length} selected" : "Notifications",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF00253A),
          ),
        ),
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.select_all, color: Color(0xFF00253A)),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('alerts')
                  .where('userId', isEqualTo: userId)
                  .get()
                  .then((snapshot) => _selectAll(snapshot.docs));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSelected,
          ),
        ]
            : [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: StreamBuilder<QuerySnapshot>(
            stream: _getAlertsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final alerts = snapshot.data!.docs;

              if (alerts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notifications_off, size: 60, color: Color(0xFF00253A)),
                      SizedBox(height: 12),
                      Text(
                        'No new alerts!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00253A),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final docId = alert.id;
                  final message = alert['message'];
                  final timestamp = (alert['timestamp'] as Timestamp?)?.toDate();
                  final formattedDate = timestamp != null
                      ? DateFormat.yMMMd().add_jm().format(timestamp)
                      : 'Unknown time';
                  final isRead = alert['isRead'] == true;
                  final isSelected = selectedIds.contains(docId);

                  _markAsRead(alert);

                  return GestureDetector(
                    onLongPress: () => _toggleSelection(docId),
                    onTap: () {
                      if (isSelectionMode) {
                        _toggleSelection(docId);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade100
                            : isRead
                            ? Colors.white
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.notifications_active_rounded, color: Colors.indigo),
                        title: Text(
                          message,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF00253A),
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        trailing: isSelectionMode
                            ? Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.green : Colors.grey,
                        )
                            : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}