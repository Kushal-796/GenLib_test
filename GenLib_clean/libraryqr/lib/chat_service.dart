import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import for Future.delayed

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey = "AIzaSyBp0AYadobdklW1ton3egVuT9_niR3T4hk";
  final String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";

  // Caching mechanism
  String? _bookContextCache;

  Future<String> _getBookContext() async {
    if (_bookContextCache != null) {
      return _bookContextCache!;
    }
    final booksSnapshot = await _firestore.collection('books').get();
    if (booksSnapshot.docs.isEmpty) {
      return "No books found.";
    }
    final bookData = booksSnapshot.docs.map((doc) {
      final data = doc.data();
      return "- **Title:** ${data['title']}, **Author:** ${data['author']}, **Genre:** ${data['genre']}, **Available Copies:** ${data['count']}";
    }).join('\n');
    _bookContextCache = "Here is the list of all available books:\n$bookData";
    return _bookContextCache!;
  }

  Future<String> getChatbotResponse(String userInput) async {
    try {
      final bookContext = await _getBookContext();
      if (bookContext == "No books found.") {
        return "I'm sorry, there are no books in the library database right now.";
      }

      final prompt = """
      You are a helpful library assistant named Gen-Lib.
      Your knowledge is STRICTLY limited to the information provided in the book list below.

      **CRITICAL RULES:**
      0.  If the user provides a simple greeting like "hi" or "hello", respond with a friendly greeting and then state your purpose (e.g., "Hello! I'm Gen-Lib, your library assistant. How can I help you with our book collection today?").
      1.  Format your answers using Markdown. Use bullet points for lists and bold text for titles.
      2.  If the user asks about a specific book that is NOT in the list, you MUST respond with ONLY this sentence: "I'm sorry, I could not find that book in our library." Do not add any other information.
      3.  If the user's question is not about the books in the list, you MUST respond with ONLY this sentence: "I can only answer questions about the books in our library."

      $bookContext

      User's question: "$userInput"
      """;

      // --- IMPLEMENTED RETRY LOGIC ---
      int retries = 0;
      const maxRetries = 3;
      int delay = 2; // Initial delay in seconds

      while (retries < maxRetries) {
        final response = await http.post(
          Uri.parse('$_apiUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final body = json.decode(response.body);
          if (body['candidates'] != null &&
              body['candidates'].isNotEmpty &&
              body['candidates'][0]['content'] != null &&
              body['candidates'][0]['content']['parts'] != null &&
              body['candidates'][0]['content']['parts'].isNotEmpty) {
            return body['candidates'][0]['content']['parts'][0]['text'];
          } else {
            return "I'm sorry, I can't respond to that. Please ask me about books.";
          }
        } else if (response.statusCode == 503 && retries < maxRetries - 1) {
          // If it's a traffic error and we haven't exhausted retries, wait and try again.
          await Future.delayed(Duration(seconds: delay));
          delay *= 2; // Exponential backoff
          retries++;
        } else {
          // For any other error, or if retries are exhausted, fail gracefully.
          if (kDebugMode) {
            print('API Error Response: ${response.body}');
          }
          if (response.statusCode == 503) {
            return "The AI assistant is still experiencing high traffic after multiple attempts. Please try again in a few moments.";
          }
          return "Error: Could not get a response from the AI. Status code: ${response.statusCode}";
        }
      }
      // This part is reached only if all retries fail with a 503 error.
      return "The AI assistant is currently experiencing high traffic. Please try again in a few moments.";
    } catch (e) {
      if (kDebugMode) {
        print('Service Error: $e');
      }
      return "An error occurred while fetching data. Please check your connection.";
    }
  }
}