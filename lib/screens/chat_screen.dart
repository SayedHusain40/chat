import 'package:chat/widgets/chat_messages_list.dart';
import 'package:chat/widgets/chat_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void onSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showMessage('Something Went Wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart'),
        actions: [IconButton(onPressed: onSignOut, icon: Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: ChatMessagesList()),
            ChatInput(),
          ],
        ),
      ),
    );
  }
}
