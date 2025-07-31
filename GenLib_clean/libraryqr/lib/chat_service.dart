// //Gemini API
//
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'dart:async'; // Import for Future.delayed
// //
// // class ChatService {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final String _apiKey = "AIzaSyBp0AYadobdklW1ton3egVuT9_niR3T4hk";
// //   final String _apiUrl =
// //       "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";
// //
// //   // Caching mechanism
// //   String? _bookContextCache;
// //
// //   Future<String> _getBookContext() async {
// //     if (_bookContextCache != null) {
// //       return _bookContextCache!;
// //     }
// //     final booksSnapshot = await _firestore.collection('books').get();
// //     if (booksSnapshot.docs.isEmpty) {
// //       return "No books found.";
// //     }
// //     final bookData = booksSnapshot.docs.map((doc) {
// //       final data = doc.data();
// //       return "- **Title:** ${data['title']}, **Author:** ${data['author']}, **Genre:** ${data['genre']}, **Available Copies:** ${data['count']}";
// //     }).join('\n');
// //     _bookContextCache = "Here is the list of all available books:\n$bookData";
// //     return _bookContextCache!;
// //   }
// //
// //   Future<String> getChatbotResponse(String userInput) async {
// //     try {
// //       final bookContext = await _getBookContext();
// //       if (bookContext == "No books found.") {
// //         return "I'm sorry, there are no books in the library database right now.";
// //       }
// //
// //       final prompt = """
// //       You are a helpful library assistant named Gen-Lib.
// //       Your knowledge is STRICTLY limited to the information provided in the book list below.
// //
// //       **CRITICAL RULES:**
// //       0.  If the user provides a simple greeting like "hi" or "hello", respond with a friendly greeting and then state your purpose (e.g., "Hello! I'm Gen-Lib, your library assistant. How can I help you with our book collection today?").
// //       1.  Format your answers using Markdown. Use bullet points for lists and bold text for titles.
// //       2.  If the user asks about a specific book that is NOT in the list, you MUST respond with ONLY this sentence: "I'm sorry, I could not find that book in our library." Do not add any other information.
// //       3.  If the user's question is not about the books in the list, you MUST respond with ONLY this sentence: "I can only answer questions about the books in our library."
// //
// //       $bookContext
// //
// //       User's question: "$userInput"
// //       """;
// //
// //       // --- IMPLEMENTED RETRY LOGIC ---
// //       int retries = 0;
// //       const maxRetries = 3;
// //       int delay = 2; // Initial delay in seconds
// //
// //       while (retries < maxRetries) {
// //         final response = await http.post(
// //           Uri.parse('$_apiUrl?key=$_apiKey'),
// //           headers: {'Content-Type': 'application/json'},
// //           body: json.encode({
// //             'contents': [
// //               {
// //                 'parts': [
// //                   {'text': prompt}
// //                 ]
// //               }
// //             ]
// //           }),
// //         );
// //
// //         if (response.statusCode == 200) {
// //           final body = json.decode(response.body);
// //           if (body['candidates'] != null &&
// //               body['candidates'].isNotEmpty &&
// //               body['candidates'][0]['content'] != null &&
// //               body['candidates'][0]['content']['parts'] != null &&
// //               body['candidates'][0]['content']['parts'].isNotEmpty) {
// //             return body['candidates'][0]['content']['parts'][0]['text'];
// //           } else {
// //             return "I'm sorry, I can't respond to that. Please ask me about books.";
// //           }
// //         } else if (response.statusCode == 503 && retries < maxRetries - 1) {
// //           // If it's a traffic error and we haven't exhausted retries, wait and try again.
// //           await Future.delayed(Duration(seconds: delay));
// //           delay *= 2; // Exponential backoff
// //           retries++;
// //         } else {
// //           // For any other error, or if retries are exhausted, fail gracefully.
// //           if (kDebugMode) {
// //             print('API Error Response: ${response.body}');
// //           }
// //           if (response.statusCode == 503) {
// //             return "The AI assistant is still experiencing high traffic after multiple attempts. Please try again in a few moments.";
// //           }
// //           return "Error: Could not get a response from the AI. Status code: ${response.statusCode}";
// //         }
// //       }
// //       // This part is reached only if all retries fail with a 503 error.
// //       return "The AI assistant is currently experiencing high traffic. Please try again in a few moments.";
// //     } catch (e) {
// //       if (kDebugMode) {
// //         print('Service Error: $e');
// //       }
// //       return "An error occurred while fetching data. Please check your connection.";
// //     }
// //   }
// // }



// //Not using
//
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'dart:async'; // Import for Future.delayed
// //
// // class ChatService {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   // This API key will grant access to your custom model
// //   final String _apiKey = "YOUR_API_KEY_HERE";
// //
// //   // IMPORTANT: After you train your model, you will get a unique name.
// //   // You will need to replace "YOUR_TUNED_MODEL_NAME" with that name.
// //   final String _apiUrl =
// //       "https://generativelanguage.googleapis.com/v1beta/tunedModels/YOUR_TUNED_MODEL_NAME:generateContent";
// //
// //   // Caching mechanism
// //   String? _bookContextCache;
// //
// //   Future<String> _getBookContext() async {
// //     if (_bookContextCache != null) {
// //       return _bookContextCache!;
// //     }
// //     final booksSnapshot = await _firestore.collection('books').get();
// //     if (booksSnapshot.docs.isEmpty) {
// //       return "No books found.";
// //     }
// //     final bookData = booksSnapshot.docs.map((doc) {
// //       final data = doc.data();
// //       return "- **Title:** ${data['title']}, **Author:** ${data['author']}, **Genre:** ${data['genre']}\n  **Description:** ${data['description'] ?? 'No description available.'}";
// //     }).join('\n\n');
// //     _bookContextCache = "Here is the list of all available books:\n$bookData";
// //     return _bookContextCache!;
// //   }
// //
// //   Future<String> getChatbotResponse(String userInput) async {
// //     try {
// //       // NOTE: For a fine-tuned model, we no longer need to send the long list of rules and book data.
// //       // The model's training has already taught it how to behave and what it knows.
// //       // We only need to send the user's direct question.
// //       final prompt = userInput;
// //
// //       int retries = 0;
// //       const maxRetries = 3;
// //       int delay = 2;
// //
// //       while (retries < maxRetries) {
// //         final response = await http.post(
// //           Uri.parse('$_apiUrl?key=$_apiKey'),
// //           headers: {'Content-Type': 'application/json'},
// //           body: json.encode({
// //             'contents': [
// //               {
// //                 'parts': [
// //                   {'text': prompt}
// //                 ]
// //               }
// //             ]
// //           }),
// //         );
// //
// //         if (response.statusCode == 200) {
// //           final body = json.decode(response.body);
// //           if (body['candidates'] != null &&
// //               body['candidates'].isNotEmpty &&
// //               body['candidates'][0]['content'] != null &&
// //               body['candidates'][0]['content']['parts'] != null &&
// //               body['candidates'][0]['content']['parts'].isNotEmpty) {
// //             return body['candidates'][0]['content']['parts'][0]['text'];
// //           } else {
// //             return "The model returned an empty response. Please try rephrasing.";
// //           }
// //         }
// //         else if (response.statusCode == 429) {
// //           return "You're sending messages too quickly. Please wait a moment.";
// //         }
// //         else if (response.statusCode == 503 && retries < maxRetries - 1) {
// //           await Future.delayed(Duration(seconds: delay));
// //           delay *= 2;
// //           retries++;
// //         } else {
// //           if (kDebugMode) {
// //             print('API Error Response: ${response.body}');
// //           }
// //           if (response.statusCode == 503) {
// //             return "The model is currently experiencing high traffic. Please try again in a few moments.";
// //           }
// //           return "Error: Could not get a response from the AI. Status code: ${response.statusCode}";
// //         }
// //       }
// //       return "The AI model is currently experiencing high traffic. Please try again.";
// //     } catch (e) {
// //       if (kDebugMode) {
// //         print('Service Error: $e');
// //       }
// //       return "An error occurred. Please check your connection.";
// //     }
// //   }
// // }
//
//
// // import 'dart:convert';
// // import 'package:flutter/services.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// //
// // // Represents a single book's data, fetched from Firebase
// // class Book {
// //   final String title;
// //   final String author;
// //   final String genre;
// //   final String description;
// //   final int count;
// //
// //   Book({
// //     required this.title,
// //     required this.author,
// //     required this.genre,
// //     required this.description,
// //     required this.count,
// //   });
// // }
// //
// // class ChatService {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   // --- LOCAL AI MODEL VARIABLES ---
// //   Interpreter? _interpreter;
// //   Map<String, dynamic>? _tokenizer;
// //   List<dynamic>? _labels;
// //   int _maxSequenceLen = 0;
// //
// //   // --- DATA CACHE ---
// //   List<Book>? _bookCache;
// //
// //   // --- INITIALIZATION ---
// //   ChatService() {
// //     _loadModelAndData();
// //   }
// //
// //   // Loads all necessary assets: the ML model, tokenizer, labels, and book data
// //   Future<void> _loadModelAndData() async {
// //     if (_interpreter != null) return; // Load only once
// //
// //     try {
// //       // Load the TensorFlow Lite model
// //       _interpreter = await Interpreter.fromAsset('assets/ml/intent_model.tflite');
// //
// //       // Load the tokenizer
// //       final tokenizerJsonString = await rootBundle.loadString('assets/ml/tokenizer.json');
// //       _tokenizer = json.decode(tokenizerJsonString);
// //
// //       // This value must match the 'max_sequence_len' from your Python training script
// //       _maxSequenceLen = 11;
// //
// //       // Load the labels
// //       final labelsJson = await rootBundle.loadString('assets/ml/labels.json');
// //       _labels = json.decode(labelsJson);
// //
// //       // Load the book data from Firebase
// //       await _loadBookDataFromFirebase();
// //     } catch (e) {
// //       print("Error loading model or assets: $e");
// //     }
// //   }
// //
// //   // Fetches all book data from Firestore and populates the cache
// //   Future<void> _loadBookDataFromFirebase() async {
// //     try {
// //       final booksSnapshot = await _firestore.collection('books').get();
// //       _bookCache = [];
// //       for (var doc in booksSnapshot.docs) {
// //         final data = doc.data();
// //         _bookCache!.add(
// //           Book(
// //             title: data['title'] ?? 'Unknown Title',
// //             author: data['author'] ?? 'Unknown Author',
// //             genre: data['genre'] ?? 'Unknown Genre',
// //             description: data['description'] ?? 'No description available.',
// //             count: data['count'] ?? 0,
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       print("Error fetching books from Firebase: $e");
// //     }
// //   }
// //
// //   // --- CORE AI LOGIC ---
// //
// //   // Preprocesses the user's text input into a format the model can understand
// //   List<List<double>> _preprocessText(String text) {
// //     // The tokenizer saved from Keras is a JSON string within a JSON object
// //     final wordIndex = Map<String, int>.from(json.decode(_tokenizer!['config'])['word_index']);
// //     final sequence = List<int>.filled(_maxSequenceLen, 0);
// //     final words = text.toLowerCase().split(' ');
// //     for (var i = 0; i < words.length && i < _maxSequenceLen; i++) {
// //       sequence[i] = wordIndex[words[i]] ?? 0; // Use 0 for unknown words
// //     }
// //     // Model expects a 2D list of doubles
// //     return [sequence.map((e) => e.toDouble()).toList()];
// //   }
// //
// //   // Uses the loaded model to predict the user's intent
// //   String _predictIntent(String text) {
// //     if (_interpreter == null || _tokenizer == null || _labels == null) {
// //       return 'error';
// //     }
// //     final preprocessedInput = _preprocessText(text);
// //
// //     // The output tensor needs to be a 2D list as well
// //     final outputTensor = [List<double>.filled(_labels!.length, 0.0)];
// //
// //     _interpreter!.run(preprocessedInput, outputTensor);
// //
// //     final predictions = outputTensor[0];
// //     int maxIndex = 0;
// //     for (int i = 1; i < predictions.length; i++) {
// //       if (predictions[i] > predictions[maxIndex]) {
// //         maxIndex = i;
// //       }
// //     }
// //     return _labels![maxIndex];
// //   }
// //
// //   // Extracts a book title from the user's query
// //   Book? _findBookInQuery(String input) {
// //     for (var book in _bookCache!) {
// //       if (input.toLowerCase().contains(book.title.toLowerCase())) {
// //         return book;
// //       }
// //     }
// //     return null;
// //   }
// //
// //   // The main function that gets the chatbot's response
// //   Future<String> getChatbotResponse(String userInput) async {
// //     await _loadModelAndData(); // Ensure everything is loaded
// //
// //     if (_bookCache == null) {
// //       return "I'm sorry, I'm having trouble loading the library data. Please try again in a moment.";
// //     }
// //
// //     final intent = _predictIntent(userInput);
// //     final input = userInput.toLowerCase();
// //
// //     switch (intent) {
// //       case 'greeting':
// //         return "Hello! I'm Gen-Lib, your library assistant. How can I help you with our book collection today?";
// //
// //       case 'get_description':
// //         final book = _findBookInQuery(input);
// //         if (book != null) {
// //           final availability = book.count > 0 ? "Available (${book.count} copies)" : "Currently unavailable";
// //           return "**${book.title}**\n\n*Status: $availability*\n\n${book.description}";
// //         }
// //         return "Which book would you like to know about?";
// //
// //       case 'find_author':
// //         final book = _findBookInQuery(input);
// //         if (book != null) {
// //           return "The author of **${book.title}** is ${book.author}.";
// //         }
// //         return "Which book are you asking about?";
// //
// //       case 'find_genre':
// //         final book = _findBookInQuery(input);
// //         if (book != null) {
// //           return "**${book.title}** is in the **${book.genre}** genre.";
// //         }
// //         return "Which book's genre would you like to know?";
// //
// //       case 'find_books_by_author':
// //         final authorName = input.split('by').last.trim();
// //         final booksByAuthor = _bookCache!.where((b) => b.author.toLowerCase().contains(authorName)).toList();
// //         if (booksByAuthor.isNotEmpty) {
// //           return "Here are the books we have by **${booksByAuthor.first.author}**:\n\n" + booksByAuthor.map((b) => "- ${b.title}").join('\n');
// //         }
// //         return "I'm sorry, I couldn't find any books by an author with that name.";
// //
// //       case 'list_genre':
// //       // A simple way to extract the genre from the query
// //         String? foundGenre;
// //         for (var book in _bookCache!) {
// //           if (input.contains(book.genre.toLowerCase())) {
// //             foundGenre = book.genre;
// //             break;
// //           }
// //         }
// //         if (foundGenre != null) {
// //           final booksInGenre = _bookCache!.where((b) => b.genre == foundGenre).toList();
// //           return "Here are the books in the **$foundGenre** genre:\n\n" + booksInGenre.map((b) => "- ${b.title} by ${b.author}").join('\n');
// //         }
// //         return "Which genre are you interested in?";
// //
// //       case 'list_all_books':
// //         return "Of course! Here is a list of all our books:\n\n" + _bookCache!.map((b) => "- **${b.title}** by ${b.author}").join('\n');
// //
// //       case 'find_book':
// //         return "I'm sorry, I could not find that book in our library.";
// //
// //       case 'irrelevant':
// //       default:
// //         return "I can only answer questions about the books in our library.";
// //     }
// //   }
// // }

//Rule Based AI

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single book's data, fetched from Firebase
class Book {
  final String title;
  final String author;
  final String genre;
  final String description;
  // ADDED: The count of available copies
  final int count;

  Book({
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.count,
  });
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Caching mechanism to hold the book data
  List<Book>? _bookCache;

  // Fetches all book data from Firestore and populates the cache
  Future<void> _loadBookData() async {
    if (_bookCache != null) return; // Load only once

    final booksSnapshot = await _firestore.collection('books').get();
    _bookCache = [];
    for (var doc in booksSnapshot.docs) {
      final data = doc.data();
      _bookCache!.add(
        Book(
          title: data['title'] ?? 'Unknown Title',
          author: data['author'] ?? 'Unknown Author',
          genre: data['genre'] ?? 'Unknown Genre',
          description: data['description'] ?? 'No description available.',
          // ADDED: Fetching the count from Firebase
          count: data['count'] ?? 0,
        ),
      );
    }
  }

  // The main function that processes user input and returns a response
  Future<String> getChatbotResponse(String userInput) async {
    // Ensure book data is loaded before proceeding
    await _loadBookData();

    if (_bookCache == null || _bookCache!.isEmpty) {
      return "I'm sorry, I don't have any book information right now. Please check your connection and try again.";
    }

    final input = userInput.toLowerCase().trim();

    // --- Rule 1: Handle Greetings ---
    if (input == 'hi' || input == 'hello' || input == 'hey') {
      return "Hello! I'm Gen-Lib, your library assistant. You can ask me about a book's author, genre, or description.";
    }

    // --- Rule to list all available books ---
    if (input.contains('available books') || input.contains('what books are available')) {
      final availableBooks = _bookCache!.where((book) => book.count > 0).toList();
      if (availableBooks.isNotEmpty) {
        return "Of course! Here are the books currently available:\n\n" +
            availableBooks.map((b) => "- **${b.title}** by ${b.author} (${b.count} copies)").join('\n');
      } else {
        return "I'm sorry, it looks like there are no books available for borrowing right now.";
      }
    }

    // --- Rule 2: Find the book the user is asking about ---
    Book? foundBook;
    for (var book in _bookCache!) {
      if (input.contains(book.title.toLowerCase())) {
        foundBook = book;
        break;
      }
    }

    // If a book was mentioned in the input, answer based on keywords
    if (foundBook != null) {
      // --- UPDATED: More robust rule to check availability of a specific book ---
      if (input.contains('available') || input.contains('availability') || input.contains('avilable')) {
        if (foundBook.count > 0) {
          return "Yes, **${foundBook.title}** is available. We have ${foundBook.count} copies.";
        } else {
          return "I'm sorry, **${foundBook.title}** is currently not available.";
        }
      }

      // --- Rule 3: Answer questions about the description (now includes availability) ---
      if (input.contains('about') || input.contains('description') || input.contains('tell me about')) {
        final availability = foundBook.count > 0 ? "Available (${foundBook.count} copies)" : "Currently unavailable";
        return "**${foundBook.title}**\n\n*Status: $availability*\n\n${foundBook.description}";
      }
      // --- Rule 4: Answer questions about the author ---
      if (input.contains('who wrote') || input.contains('author')) {
        return "The author of **${foundBook.title}** is ${foundBook.author}.";
      }
      // --- Rule 5: Answer questions about the genre ---
      if (input.contains('what genre') || input.contains('genre of')) {
        return "**${foundBook.title}** is in the **${foundBook.genre}** genre.";
      }
      // Default response if a book is mentioned but the question is unclear
      return "I have information about **${foundBook.title}**. What would you like to know? You can ask about its author, genre, description, or availability.";
    }

    // --- Rule 6: Handle generic questions about authors or genres ---
    if (input.contains('books by')) {
      // Example: "books by shakespeare"
      final authorName = input.split('books by')[1].trim();
      final booksByAuthor = _bookCache!.where((book) => book.author.toLowerCase().contains(authorName)).toList();
      if (booksByAuthor.isNotEmpty) {
        return "Here are the books we have by ${booksByAuthor.first.author}:\n\n" + booksByAuthor.map((b) => "- **${b.title}**").join('\n');
      } else {
        return "I'm sorry, I couldn't find any books by an author with that name.";
      }
    }

    // --- NEW: Final fallback rule for when no book is found ---
    return "I'm sorry, I could not find that book in our library.";
  }
}
