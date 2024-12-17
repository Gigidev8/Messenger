import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/screens/homepages/chat_ui/chat_screen.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/add_friends/addfriend_screen.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/bottomsheeet.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/friends_list/friends_list.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/pendingreply_.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/profile_imageget.dart';
import 'package:rxdart/rxdart.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Stream<QuerySnapshot> _fetchChats() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .where('user1', isEqualTo: currentUser.email)
        .snapshots(includeMetadataChanges: true)
        .asBroadcastStream()
        .mergeWith([
      FirebaseFirestore.instance
          .collection('chats')
          .where('user2', isEqualTo: currentUser.email)
          .snapshots(includeMetadataChanges: true),
    ]);
  }

  Future<Map<String, dynamic>> _fetchUserDetails(String userEmail) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // Assuming 'users' collection
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'name': 'Unknown User',
          'profilePicture': '',
        };
      }

      final userData = snapshot.docs.first.data();
      return {
        'name': userData['name'] ?? 'Unknown User',
        'profilePicture': userData['profileImage'] ?? '',
      };
    } catch (e) {
      return {
        'name': 'Unknown User',
        'profilePicture': '',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: const ProfileImageWidget(),
          title: Text(
            "Ping Me",
            style: TextStyle(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.list, color: theme.colorScheme.tertiary),
              onPressed: () {
                SettingsBottomSheet.showSettingsBottomSheet(context);
              },
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: Column(
          children: [
            PendingReplyNotification(
              onAddFriendPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFriendScreen()),
                );
              },
              onPingsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendsListScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No active chats yet.",
                        style: TextStyle(color: theme.colorScheme.tertiary),
                      ),
                    );
                  }

                  final chats = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index].data() as Map<String, dynamic>;
                      final isUser1 =
                          chat['user1'] == FirebaseAuth.instance.currentUser!.email;
                      final friendEmail = isUser1 ? chat['user2'] : chat['user1'];
                      final lastMessage = chat['lastMessage'] ?? "No messages yet.";
                      final lastTimestamp = chat['lastTimestamp'] != null
                          ? (chat['lastTimestamp'] as Timestamp)
                              .toDate()
                              .toLocal()
                              .toString()
                              .substring(0, 16)
                          : "Unknown";

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _fetchUserDetails(friendEmail),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final userDetails = userSnapshot.data ?? {
                            'name': 'Unknown User',
                            'profilePicture': '',
                          };

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.background,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: theme.colorScheme.secondary, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8.0),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      theme.colorScheme.secondary.withOpacity(0.2),
                                  backgroundImage: userDetails['profilePicture'].isNotEmpty
                                      ? (userDetails['profilePicture'].startsWith('http')
                                          ? NetworkImage(userDetails['profilePicture'])
                                          : MemoryImage(base64Decode(
                                              userDetails['profilePicture'])) as ImageProvider)
                                      : const AssetImage('assets/images/default_avatar.png'),
                                  radius: 25,
                                ),
                                title: Text(
                                  userDetails['name'],
                                  style: TextStyle(
                                    color: theme.colorScheme.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  lastMessage,
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  lastTimestamp,
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          chatId: chats[index].id,
                                          friendId: friendEmail),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}