import 'package:chat/utils/firebase_error_messages.dart';
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

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void onSendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final id = FirebaseAuth.instance.currentUser!.uid;

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      await FirebaseFirestore.instance.collection('chats').add({
        'id': id,
        'userName': userData.data()!['name'],
        'message': messageController.text.trim(),
        'image_url': userData.data()!['image_url'],
        'createdAt': Timestamp.now(),
      });

      messageController.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } on FirebaseException catch (e) {
      if (e.plugin == 'cloud_firestore') {
        showMessage(getFirestoreMessage(e));
      } else {
        showMessage("Something went wrong.");
      }
    } catch (e) {
      showMessage('Something Went Wrong');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
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
