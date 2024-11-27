import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_state.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatCode = Provider.of<ChatState>(context).chatCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room: $chatCode'),
      ),
      body: const Center(
        child: Text('Chat interface will go here'),
      ),
    );
  }
}
