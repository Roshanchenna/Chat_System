import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'chat_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

void main() async {
  // Load environment variables before the app runs
  await dotenv.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false; // To show loading indicator while creating code

  Future<void> _createChat() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Fetch the backend URL from environment variables
      String backendUrl = '${dotenv.env['BACKEND_URL']}/api/create-room' ??
          'https://default-url.com';

      // Make the API call to the backend to get a random 4-digit code
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        // Parse the response and get the code (assuming it's a JSON with a field 'code')
        var jsonResponse = jsonDecode(response.body);
        String randomCode = jsonResponse['code'];

        // Set the chat code in the state
        Provider.of<ChatState>(context, listen: false).setChatCode(randomCode);

        // Navigate to the chat screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      } else {
        // Handle error if the API call fails
        throw Exception('Failed to load code');
      }
    } catch (e) {
      // Handle any error that occurs
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error creating chat code. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  void _joinChat() {
    String code = _codeController.text.trim();
    if (code.isNotEmpty) {
      Provider.of<ChatState>(context, listen: false).setChatCode(code);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Chat App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter or generate a chat code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed:
                      _isLoading ? null : _createChat, // Disable when loading
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create'),
                ),
                ElevatedButton(
                  onPressed: _joinChat,
                  child: const Text('Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
