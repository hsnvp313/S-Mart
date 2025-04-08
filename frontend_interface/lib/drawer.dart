import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Error loading user data'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['username'] ?? 'User Name';
          final email = userData['email'] ?? 'user@example.com';
          final profilePicUrl =
              userData['profile_picture'] ?? ''; // Ensure correct Firestore key

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(username),
                accountEmail: Text(email),
                currentAccountPicture: profilePicUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePicUrl),
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person,
                            size: 40, color: Colors.teal.shade100),
                        backgroundColor: Colors.teal,
                      ),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.teal),
                title: const Text('Wallet'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/wallet');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                title: const Text('Cart Summary'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/cartSummary',
                      arguments: userId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.teal),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
