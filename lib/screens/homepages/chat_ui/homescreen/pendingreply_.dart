import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingReplyNotification extends StatelessWidget {
  final Function onAddFriendPressed;
  final Function onPingsPressed;

  const PendingReplyNotification({
    Key? key,
    required this.onAddFriendPressed,
    required this.onPingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => onAddFriendPressed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    "Add new Friend",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => onPingsPressed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    "friends",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
