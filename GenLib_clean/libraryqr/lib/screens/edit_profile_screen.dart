import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _email = user.email;
        _nameController.text = doc['name'] ?? '';
      });
    }
  }

  Future<void> _updateName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Name updated')));
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: _email!,
      password: _currentPasswordController.text,
    );

    try {
      await user!.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔐 Password changed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📩 Password reset email sent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAF8),
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF00253A),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00253A)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateName,
                child: const Text('Update Name'),
              ),
              const Divider(height: 32),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Change Password'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _sendPasswordResetEmail,
                child: const Text('Forgot Password? Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
