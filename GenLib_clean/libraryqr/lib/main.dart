import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:libraryqr/screens/alerts_screen.dart';
import 'package:libraryqr/screens/user_wishlist_screen.dart';

import 'screens/login_screen.dart';
import 'screens/user_book_list_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/admin_available_books_screen.dart'; // Admin screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _getHomeScreen(User? user) {
    if (user == null) {
      return const LoginScreen(); // No session
    }

    if (user.email == 'kushal23241a05c7@grietcollege.com') {
      return const AdminAvailableBooksScreen(); // Admin
    }

    return const UserHomeScreen(); // Regular user
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gen-Lib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3FAF8),
        primaryColor: const Color(0xFF00253A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00253A),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00253A),
          ),
          iconTheme: IconThemeData(color: Color(0xFF00253A)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        fontFamily: 'Roboto',
        // Removed `margin` from CardTheme to fix error
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black12,
        ),
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const UserHomeScreen(),
        '/genreBooks': (context) {
          final genre = ModalRoute.of(context)!.settings.arguments as String;
          return UserBookListScreen(genre: genre);
        },
        '/bookList': (_) => const BookListScreen(),
        '/alerts': (_) => const AlertsScreen(),
        '/wishlist': (_) => const UserWishlistScreen(),

      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF3FAF8),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return _getHomeScreen(snapshot.data);
        },
      ),
    );
  }
}