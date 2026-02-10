import 'package:chat/widgets/avatar.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String senderName;
  final String messageText;
  final String imageUrl;
  final bool isCurrentUser;
  final bool isSameSenderAsNext;
  final double widthBtwAvatarAndMsg;

  const MessageBubble({
    super.key,
    required this.senderName,
    required this.messageText,
    required this.imageUrl,
    required this.isCurrentUser,
    required this.isSameSenderAsNext,
    required this.widthBtwAvatarAndMsg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const double avatarRadius = 25;
    const double avatarWidth = avatarRadius * 2;
    return Row(
      crossAxisAlignment: .start,
      mainAxisAlignment: isCurrentUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isCurrentUser) ...[
          if (!isSameSenderAsNext)
            Avatar(imageUrl: imageUrl, radius: avatarRadius),
          SizedBox(width: widthBtwAvatarAndMsg),
        ],

        // Message bubble
        Expanded(
          child: Column(
            mainAxisAlignment: .end,
            crossAxisAlignment: isCurrentUser ? .end : .start,
            children: [
              if (!isSameSenderAsNext)
                Text(
                  senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Container(
                margin: EdgeInsets.only(
                  left: !isCurrentUser && isSameSenderAsNext ? avatarWidth : 0,
                  right: isCurrentUser && isSameSenderAsNext ? avatarWidth : 0,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 9,
                  horizontal: 13,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Colors.grey[300]
                      : theme.colorScheme.secondary.withAlpha(200),
                  borderRadius: .only(
                    topLeft: !isCurrentUser && !isSameSenderAsNext
                        ? .zero
                        : const .circular(12),
                    topRight: isCurrentUser && !isSameSenderAsNext
                        ? .zero
                        : const .circular(12),
                    bottomLeft: const .circular(12),
                    bottomRight: const .circular(12),
                  ),
                ),
                child: Text(
                  messageText,
                  style: TextStyle(
                    color: isCurrentUser
                        ? Colors.black87
                        : theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (isCurrentUser) ...[
          SizedBox(width: widthBtwAvatarAndMsg),
          if (!isSameSenderAsNext)
            Avatar(imageUrl: imageUrl, radius: avatarRadius),
        ],
      ],
    );
  }
}
