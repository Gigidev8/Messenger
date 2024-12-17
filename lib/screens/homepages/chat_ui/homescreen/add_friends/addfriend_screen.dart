import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _searchedUser;
  bool _isRequestSent = false;
  List<Map<String, dynamic>> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  // Fetch friend requests for the current user
  Future<void> _fetchFriendRequests() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();

      if (userDoc.exists && userDoc.data() != null) {
        final List<String> friendRequestEmails = List<String>.from(userDoc['friendRequests'] ?? []);

        // Fetch user details for each email in the friendRequests list
        final requests = await Future.wait(friendRequestEmails.map((email) async {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
          return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
        }).toList());

        setState(() {
          _friendRequests = requests.where((data) => data != null).cast<Map<String, dynamic>>().toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friend requests: $e')),
      );
    }
  }

  // Accept friend request
  Future<void> _acceptFriendRequest(String senderEmail) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String currentUserEmail = currentUser.email!;
    try {
      // Add both users to each other's friends list
      await FirebaseFirestore.instance.collection('users').doc(currentUserEmail).update({
        'friends': FieldValue.arrayUnion([senderEmail]),
      });

      await FirebaseFirestore.instance.collection('users').doc(senderEmail).update({
        'friends': FieldValue.arrayUnion([currentUserEmail]),
      });

      // Remove the request from the friendRequests array
      await FirebaseFirestore.instance.collection('users').doc(currentUserEmail).update({
        'friendRequests': FieldValue.arrayRemove([senderEmail]),
      });

      setState(() {
        _friendRequests.removeWhere((user) => user['email'] == senderEmail);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are now friends with ${senderEmail.split('@')[0]}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept friend request: $e')),
      );
    }
  }

  // Decline friend request
  Future<void> _declineFriendRequest(String senderEmail) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String currentUserEmail = currentUser.email!;
    try {
      // Remove the email from the friendRequests array
      await FirebaseFirestore.instance.collection('users').doc(currentUserEmail).update({
        'friendRequests': FieldValue.arrayRemove([senderEmail]),
      });

      setState(() {
        _friendRequests.removeWhere((user) => user['email'] == senderEmail);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request from $senderEmail declined')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline friend request: $e')),
      );
    }
  }

  // Search for a user by email
  Future<void> _searchUser(String email) async {
    setState(() {
      _isSearching = true;
      _searchedUser = null;
    });

    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _searchedUser = userDoc.data() as Map<String, dynamic>;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching for user: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Send a friend request
  Future<void> _sendFriendRequest(String email) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'friendRequests': FieldValue.arrayUnion([currentUser.email]),
      });

      setState(() {
        _isRequestSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${email.split('@')[0]}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          "Add Friend",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.colorScheme.tertiary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.tertiary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for a friend by email",
                hintStyle: GoogleFonts.poppins(color: theme.colorScheme.inversePrimary),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.tertiary),
                filled: true,
                fillColor: theme.colorScheme.primaryContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) => _searchUser(query.trim()),
            ),
            const SizedBox(height: 16),

            if (_isSearching) CircularProgressIndicator(),

            if (_searchedUser != null && !_isRequestSent) ...[
              Card(
                color: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.colorScheme.secondary,
                    backgroundImage: _searchedUser!['profileImage'] != null
                        ? MemoryImage(base64Decode(_searchedUser!['profileImage']))
                        : null,
                    child: _searchedUser!['profileImage'] == null
                        ? Icon(Icons.person, size: 30, color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                  title: Text(
                    _searchedUser!['name'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  subtitle: Text(
                    _searchedUser!['email'],
                    style: GoogleFonts.poppins(color: theme.colorScheme.inversePrimary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.blue),
                    onPressed: () => _sendFriendRequest(_searchedUser!['email']),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Friend requests section
            if (_friendRequests.isNotEmpty) ...[
              Text(
                'Friend Requests',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _friendRequests.length,
                  itemBuilder: (context, index) {
                    final user = _friendRequests[index];
                    return Card(
                      color: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: theme.colorScheme.secondary,
                          backgroundImage: user['profileImage'] != null
                              ? MemoryImage(base64Decode(user['profileImage']))
                              : null,
                          child: user['profileImage'] == null
                              ? Icon(Icons.person, size: 30, color: theme.colorScheme.onPrimary)
                              : null,
                        ),
                        title: Text(
                          user['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: GoogleFonts.poppins(color: theme.colorScheme.inversePrimary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _acceptFriendRequest(user['email']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _declineFriendRequest(user['email']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Center(
                child: Text(
                  'No friend requests',
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
