// widgets/user_avatar.dart
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final Map<String, dynamic>? user;
  final double size;
  final Color backgroundColor;
  final Color textColor;
  final double? fontSize;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.fontSize,
  });

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
