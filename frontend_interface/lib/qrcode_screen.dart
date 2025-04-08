import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class QRCodeScreen extends StatelessWidget {
  final String sessionToken;
  QRCodeScreen({required this.sessionToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.store, size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text('S-mart Entry',
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Scan to Enter Store",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.teal.shade200, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: sessionToken,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('session_token', isEqualTo: sessionToken)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(color: Colors.teal);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.red));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Text('Waiting for validation...',
                              style: TextStyle(fontSize: 16));
                        } else {
                          final documentSnapshot = snapshot.data!.docs.first;
                          final data =
                              documentSnapshot.data() as Map<String, dynamic>;

                          if (data['validated'] == true) {
                            final userId = documentSnapshot.id;
                            final username = data['username'] ?? 'User';

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  title: Text("Welcome",
                                      style: TextStyle(
                                          color: Colors.teal.shade800)),
                                  content: Text("Welcome, $username!"),
                                ),
                              );
                              Future.delayed(Duration(seconds: 3), () {
                                Navigator.pop(
                                    context); // Dismiss welcome dialog
                                Navigator.pushReplacementNamed(
                                    context, '/cartSummary',
                                    arguments: userId);
                              });
                            });
                          }

                          return Column(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.teal, size: 40),
                              SizedBox(height: 8),
                              Text('Validation in progress...',
                                  style: TextStyle(color: Colors.teal)),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
