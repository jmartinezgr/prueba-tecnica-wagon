// widgets/user_avatar.dart
import 'package:flutter/material.dart';

/// Widget for displaying a user's avatar image or initials in a circular avatar.
class UserAvatar extends StatelessWidget {
  /// User information, used to extract avatar URL or initials.
  final Map<String, dynamic>? user;

  /// Diameter of the avatar.
  final double size;

  /// Background color for the avatar (if no image).
  final Color backgroundColor;

  /// Text color for the initials.
  final Color textColor;

  /// Font size for the initials (optional).
  final double? fontSize;

  /// Creates a UserAvatar widget.
  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.fontSize,
  });

  /// Returns the user's initials based on their name, or 'U' if not available.
  String _getInitials() {
    final name = user?['name']?.toString() ?? 'U';
    if (name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Builds a circular avatar with image or initials.
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      backgroundImage: user?['avatar'] != null
          ? NetworkImage(user!['avatar'])
          : null,
      child: user?['avatar'] == null
          ? Text(
              _getInitials(),
              style: TextStyle(
                fontSize: fontSize ?? size / 2.2,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )
          : null,
    );
  }
}
