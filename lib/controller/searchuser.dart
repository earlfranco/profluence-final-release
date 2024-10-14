import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/views/profile.dart';

class SearchuserForm extends StatefulWidget {
  const SearchuserForm({super.key});

  @override
  State<SearchuserForm> createState() => _SearchuserFormState();
}

class _SearchuserFormState extends State<SearchuserForm> {
  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Timer? _debounce;
  final currentUserID = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    _fetchAllUsers();
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isNotEqualTo: currentUserID.currentUser!.email)
          .get();

      List<Map<String, dynamic>> users = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterUsers();
    });
  }

  void _filterUsers() {
    String searchText = _search.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        _filteredUsers = _allUsers;
      });
      return;
    }

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        String name = user['name']?.toString().toLowerCase() ?? '';
        String email = user['email']?.toString().toLowerCase() ?? '';

        return name.contains(searchText) || email.contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search User'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _search,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Search user',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  final userID = user['id'];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfile(userID: userID),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                    ),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text(user['email'] ?? 'No email'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
