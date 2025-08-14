// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:libraryqr/screens/admin_available_books_screen.dart';
// import 'user_home_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _registerNameController = TextEditingController();
//   final _registerEmailController = TextEditingController();
//   final _registerPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);
//     try {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text;
//       final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
//       final user = userCredential.user!;
//
//       if (!user.emailVerified) {
//         await user.sendEmailVerification();
//         await FirebaseAuth.instance.signOut();
//         _showMessage("⚠️ Please verify your email. Link has been re-sent.");
//         return;
//       }
//
//       if (email == 'kushal23241a05c7@grietcollege.com') {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminAvailableBooksScreen()));
//       } else {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
//       }
//     } on FirebaseAuthException catch (e) {
//       final messages = {
//         'user-not-found': "⚠️ No user found for this email.",
//         'wrong-password': "❌ Incorrect password.",
//         'invalid-email': "❗ Invalid email format."
//       };
//       _showMessage(messages[e.code] ?? "⚠️ Login failed. Please try again.");
//     } catch (e) {
//       _showMessage("😓 Unexpected error occurred.");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _registerAccount() async {
//     final name = _registerNameController.text.trim();
//     final email = _registerEmailController.text.trim();
//     final password = _registerPasswordController.text;
//
//     if (name.isEmpty || email.isEmpty || password.length < 6) {
//       _showMessage("❗ Please fill all fields correctly");
//       return;
//     }
//     if (!email.endsWith('@grietcollege.com')) {
//       _showMessage("⚠️ Only @grietcollege.com emails are allowed");
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
//       await userCredential.user!.sendEmailVerification();
//       await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
//         'name': name,
//         'email': email,
//       });
//       _showMessage("📩 Verification email sent. Please check your inbox!");
//     } catch (e) {
//       _showMessage("⚠️ Error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showForgotPasswordDialog() {
//     final emailResetController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Reset Password"),
//         content: TextField(
//           controller: emailResetController,
//           decoration: const InputDecoration(labelText: "Enter your email"),
//           keyboardType: TextInputType.emailAddress,
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () async {
//               final email = emailResetController.text.trim();
//               if (email.isNotEmpty) {
//                 try {
//                   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//                   Navigator.pop(context);
//                   _showMessage("📩 Password reset link sent!");
//                 } catch (e) {
//                   Navigator.pop(context);
//                   _showMessage("⚠️ Error: $e");
//                 }
//               }
//             },
//             child: const Text("Send Reset Link"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _customField(
//       TextEditingController controller,
//       String label,
//       IconData icon, {
//         bool obscure = false,
//         bool isPassword = false,
//       }) {
//     bool isObscured = obscure;
//     return StatefulBuilder(
//       builder: (context, setState) => TextFormField(
//         controller: controller,
//         obscureText: isPassword ? isObscured : false,
//         style: const TextStyle(color: Color(0xFF00253A), fontWeight: FontWeight.w500),
//         decoration: InputDecoration(
//           labelText: label,
//           floatingLabelStyle: const TextStyle(color: Colors.indigo),
//           prefixIcon: Icon(icon, color: Colors.indigo),
//           suffixIcon: isPassword
//               ? IconButton(
//             icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.indigo),
//             onPressed: () => setState(() => isObscured = !isObscured),
//           )
//               : null,
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
//           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo)),
//           focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
//         ),
//         validator: (value) => value!.isEmpty ? 'Required' : null,
//       ),
//     );
//   }
//
//   Widget _customButton(String text, VoidCallback onPressed, {Color color = Colors.indigo}) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//         ),
//         child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//       ),
//     );
//   }
//
//   Widget _buildLoginForm() {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         _customField(_emailController, 'Email', Icons.email),
//         const SizedBox(height: 20),
//         _customField(_passwordController, 'Password', Icons.lock, isPassword: true, obscure: true),
//         const SizedBox(height: 8),
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: _showForgotPasswordDialog,
//             child: const Text("Forgot Password?", style: TextStyle(color: Colors.indigo)),
//           ),
//         ),
//         const SizedBox(height: 16),
//         _isLoading ? const Center(child: CircularProgressIndicator()) : _customButton("Login", _login),
//       ],
//     );
//   }
//
//   Widget _buildRegisterForm() {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         _customField(_registerNameController, 'Name', Icons.person),
//         const SizedBox(height: 20),
//         _customField(_registerEmailController, 'College Email', Icons.email),
//         const SizedBox(height: 20),
//         _customField(_registerPasswordController, 'Password', Icons.lock, isPassword: true, obscure: true),
//         const SizedBox(height: 16),
//         _isLoading ? const Center(child: CircularProgressIndicator()) : _customButton("Register", _registerAccount),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3FAF8),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 12),
//               Text(
//                 "Gen-Lib",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF00253A),
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF3FAF8),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                         color: Color(0xFFF3FAF8),
//                       ),
//                       child: TabBar(
//                         controller: _tabController,
//                         labelColor: Colors.indigo,
//                         unselectedLabelColor: Colors.grey,
//                         indicatorColor: Colors.indigo,
//                         tabs: const [Tab(text: "Login"), Tab(text: "Register")],
//                       ),
//                     ),
//                     Container(
//                       height: 460,
//                       padding: const EdgeInsets.all(16),
//                       child: Form(
//                         key: _formKey,
//                         child: TabBarView(
//                           controller: _tabController,
//                           children: [
//                             _buildLoginForm(),
//                             _buildRegisterForm(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:libraryqr/screens/admin_available_books_screen.dart';
import 'user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  // Create separate keys for each form
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user!;

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        _showMessage("⚠ Please verify your email. Link has been re-sent.");
        return;
      }

      if (email == 'kushal23241a05c7@grietcollege.com') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminAvailableBooksScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      final messages = {
        'user-not-found': "⚠ No user found for this email.",
        'wrong-password': "❌ Incorrect password.",
        'invalid-email': "❗ Invalid email format."
      };
      _showMessage(messages[e.code] ?? "⚠ Login failed. Please try again.");
    } catch (e) {
      _showMessage("😓 Unexpected error occurred.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerAccount() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;

    // Email domain constraint is removed
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });
      _showMessage("📩 Verification email sent. Please check your inbox!");
    } catch (e) {
      _showMessage("⚠ Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = userCredential.user!;

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        await userDocRef.set({
          'name': user.displayName,
          'email': user.email,
        });
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
    } catch (e) {
      _showMessage("Google Sign-In Failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: emailResetController,
          decoration: const InputDecoration(labelText: "Enter your email"),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final email = emailResetController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  _showMessage("📩 Password reset link sent!");
                } catch (e) {
                  Navigator.pop(context);
                  _showMessage("⚠ Error: $e");
                }
              }
            },
            child: const Text("Send Reset Link"),
          ),
        ],
      ),
    );
  }

  Widget _customField(TextEditingController controller, String label, IconData icon, {bool obscure = false, bool isPassword = false}) {
    bool isObscured = obscure;
    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        controller: controller,
        obscureText: isPassword ? isObscured : false,
        style: const TextStyle(color: Color(0xFF00253A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: const TextStyle(color: Colors.indigo),
          prefixIcon: Icon(icon, color: Colors.indigo),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.indigo),
            onPressed: () => setState(() => isObscured = !isObscured),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _customButton(String text, VoidCallback onPressed, {Color color = Colors.indigo}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _googleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _signInWithGoogle,
        icon: Image.asset('assets/icon/google_icon.jpg', height: 22.0),
        label: const Text(
          "Sign in with Google",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.grey)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // Each form is wrapped in a SingleChildScrollView
  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _customField(_emailController, 'Email', Icons.email),
            const SizedBox(height: 20),
            _customField(_passwordController, 'Password', Icons.lock, isPassword: true, obscure: true),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.indigo)),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                _customButton("Login", _login),
                const SizedBox(height: 12),
                const Text("OR", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                _googleSignInButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _customField(_registerNameController, 'Name', Icons.person),
            const SizedBox(height: 20),
            _customField(_registerEmailController, 'Email', Icons.email),
            const SizedBox(height: 20),
            _customField(_registerPasswordController, 'Password', Icons.lock, isPassword: true, obscure: true),
            const SizedBox(height: 24),
            _isLoading ? const Center(child: CircularProgressIndicator()) : _customButton("Register", _registerAccount),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      body: SafeArea(
        // This Column is now the main layout, it is NOT scrollable
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 24.0),
              child: Text(
                "Gen-Lib",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00253A),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
              tabs: const [Tab(text: "Login"), Tab(text: "Register")],
            ),
            // Expanded forces the TabBarView to fill the remaining space
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginForm(),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}