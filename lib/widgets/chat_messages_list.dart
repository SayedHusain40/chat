import 'package:chat/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessagesList extends StatefulWidget {
  const ChatMessagesList({super.key});

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('There are no messages'));
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.separated(
          itemCount: chatDocs.length,
          reverse: true,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final senderName = chatDoc['userName'];
            final messageText = chatDoc['message'];
            final imageUrl = chatDoc['image_url'];
            final bool isCurrentUser = currentUserId == chatDoc['id'];

            final bool hasNextMessage = index + 1 < chatDocs.length;
            final bool isSameSenderAsNext =
                hasNextMessage && chatDoc['id'] == chatDocs[index + 1]['id'];

            return  MessageBubble(
              senderName: senderName,
              messageText: messageText,
              imageUrl: imageUrl,
              isCurrentUser: isCurrentUser,
              isSameSenderAsNext: isSameSenderAsNext,
              widthBtwAvatarAndMsg: 10,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 3),
        );
      },
    );
  }
}
