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
      final firebaseAuth = FirebaseAuth.instance.currentUser;

    if (messageController.text.trim().isEmpty || firebaseAuth == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final id = firebaseAuth.uid;
      final displayName = firebaseAuth.displayName;
      final photoURL = firebaseAuth.photoURL;

      await FirebaseFirestore.instance.collection('chats').add({
        'id': id,
        'userName': displayName,
        'message': messageController.text.trim(),
        'image_url': photoURL,
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
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              label: Text('Message'),
              hint: Text('Send a message...'),
            ),
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : onSendMessage,
          icon: _isLoading
              ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.send),
        ),
      ],
    );
  }
}
