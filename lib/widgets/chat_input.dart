import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController messageController = TextEditingController();

  bool _isLoading = false;

  void onSendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final firebaseAuth = FirebaseAuth.instance;
      final id = firebaseAuth.currentUser!.uid;
      final userName = firebaseAuth.currentUser?.displayName;
      await FirebaseFirestore.instance.collection('chats').add({
        'id': id,
        'userName': userName,
        'message': messageController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      messageController.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              label: Text('Message'),
              hint: Text('Send a message...'),
            ),
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : onSendMessage,
          icon: _isLoading
              ? SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(),
                )
              : Icon(Icons.send),
        ),
      ],
    );
  }
}
