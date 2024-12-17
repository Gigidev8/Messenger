import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String friendId;

  const ChatScreen({super.key, required this.chatId, required this.friendId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? friendName;
  String? profileImageUrl;

  // Fetch the friend's details (name and profile picture)
  Future<void> _fetchFriendDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();

      if (userDoc.exists) {
        setState(() {
          friendName = userDoc['name']; // Assuming 'name' is the field for friend's name
          profileImageUrl = userDoc['profileImage']; // Assuming 'profileImage' is the field for the profile image URL
        });
      }
    } catch (e) {
      debugPrint('Error fetching friend details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFriendDetails(); // Fetch friend details when the screen is initialized
  }

  // Send a message to Firestore
  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add the message to Firestore
    await FirebaseFirestore.instance.collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': currentUser.email,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the last message and timestamp in the chat document
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).set({
      'user1': currentUser.email,
      'user2': widget.friendId,
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _messageController.clear();  // Clear the input field
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: theme.colorScheme.tertiary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : AssetImage("lib/assets/images/user.png") as ImageProvider,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friendName ?? 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                Text(
                  "Online",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Icon(Icons.call, color: theme.colorScheme.tertiary),
          const SizedBox(width: 15),
          Icon(Icons.videocam, color: theme.colorScheme.tertiary),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(widget.chatId)
                .collection('messages')
                .orderBy('timestamp')
                .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSentByMe = message['senderId'] == FirebaseAuth.instance.currentUser?.email;
                    return MessageBubble(
                      message: message['text'],
                      isSentByMe: isSentByMe,
                      time: message['timestamp'] != null
                          ? (message['timestamp'] as Timestamp).toDate().toLocal().toString().substring(11, 16)
                          : "Unknown",
                    );
                  },
                );
              },
            ),
          ),

          // Typing Indicator
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : AssetImage("lib/assets/images/user.png") as ImageProvider,
                ),
                const SizedBox(width: 8),
                Text(
                  "Leader-nim is typing...",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type here",
                      hintStyle: GoogleFonts.poppins(
                          color: theme.colorScheme.inversePrimary),
                      prefixIcon: const Icon(Icons.add, color: Colors.purple),
                      filled: true,
                      fillColor: theme.colorScheme.primary,
                      contentPadding: const EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String time;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Colors.purple.shade300
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isSentByMe ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight:
                isSentByMe ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.poppins(
                color: isSentByMe ? Colors.white : theme.colorScheme.tertiary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isSentByMe ? Colors.white70 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceMessageBubble extends StatelessWidget {
  final String duration;
  final String time;
  final bool isSentByMe;

  const VoiceMessageBubble({
    super.key,
    required this.duration,
    required this.time,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      message: "🔊 $duration",
      isSentByMe: isSentByMe,
      time: time,
    );
  }
}
