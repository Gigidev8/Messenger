import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/screens/homepages/chat_ui/chat_screen.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchFriends() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final List<String> friendsEmails = List<String>.from(userDoc['friends'] ?? []);

        // Fetch user details for each email in the friends array
        final friends = await Future.wait(friendsEmails.map((email) async {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
          return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
        }).toList());

        return friends.where((data) => data != null).cast<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
    }
    return [];
  }

  // Function to generate chat ID
  String generateChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1\_$userId2'
        : '$userId2\_$userId1';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          "Friends List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.colorScheme.tertiary,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No friends added yet.",
                style: TextStyle(color: theme.colorScheme.tertiary),
              ),
            );
          }

          final friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: theme.colorScheme.surface, // Matches theme surface
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.purple.shade300, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: theme.colorScheme.secondary, // Avatar background
                      backgroundImage: friend['profileImage'] != null
                          ? MemoryImage(base64Decode(friend['profileImage']))
                          : null,
                      child: friend['profileImage'] == null
                          ? Icon(
                              Icons.person,
                              size: 30,
                              color: theme.colorScheme.inversePrimary, // Matches text contrast
                            )
                          : null,
                    ),
                    title: Text(
                      friend['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary, // Matches primary text
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: theme.colorScheme.tertiary, // Matches icons and text
                      ),
                      onPressed: () {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null) return;

                        final friendId = friend['email']; // Assuming 'email' is the identifier for the friend
                        String chatId = generateChatId(currentUser.email!, friendId);

                        // Navigate to the chat screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(chatId: chatId, friendId: friendId),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

