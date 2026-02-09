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
    final double avatarRadius = 25;
    final double avatarDiameter = avatarRadius * 2;
    final double avatarSpacing = 10;

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
            final senderName = chatDoc['userName'] ?? "Unknown";
            final messageText = chatDoc['message'] ?? "";
            final bool isCurrentUser = currentUserId == chatDoc['id'];

            final bool hasNextMessage = index + 1 < chatDocs.length;
            final bool isSameSenderAsNext =
                hasNextMessage && chatDoc['id'] == chatDocs[index + 1]['id'];

            final avatarLetter = senderName[0].toUpperCase();

            return Row(
              mainAxisAlignment: isCurrentUser ? .end : .start,
              children: [
                if (!isCurrentUser) ...[
                  Visibility(
                    visible: !isSameSenderAsNext,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: CircleAvatar(
                      radius: avatarRadius,
                      child: Text(avatarLetter),
                    ),
                  ),
                  SizedBox(width: avatarSpacing),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: isCurrentUser ? .end : .start,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(fontWeight: .bold),
                      ),
                      Container(
                        margin: .only(
                          left: isCurrentUser
                              ? avatarSpacing + avatarDiameter
                              : 0,
                          right: isCurrentUser
                              ? 0
                              : avatarSpacing + avatarDiameter,
                        ),
                        padding: const .symmetric(vertical: 9, horizontal: 13),
                        decoration: BoxDecoration(
                          color: const .fromARGB(255, 235, 232, 232),
                          borderRadius: .only(
                            topLeft: isCurrentUser
                                ? const .circular(12)
                                : .zero,
                            topRight: isCurrentUser
                                ? .zero
                                : const .circular(12),
                            bottomLeft: const .circular(12),
                            bottomRight: const .circular(12),
                          ),
                        ),
                        child: Text(messageText, softWrap: true),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser) ...[
                  SizedBox(width: avatarSpacing),
                  Visibility(
                    visible: !isSameSenderAsNext,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: CircleAvatar(
                      radius: avatarRadius,
                      child: Text(avatarLetter),
                    ),
                  ),
                ],
              ],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        );
      },
    );
  }
}
