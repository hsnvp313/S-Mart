import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'app_name_heading.dart';

class CheckoutScreen extends StatefulWidget {
  final String checkoutToken;
  CheckoutScreen({required this.checkoutToken});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Icon(Icons.exit_to_app, size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Exit Verification',
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(24),
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
                    Text("Scan to Exit",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade800)),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.teal.shade200, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: widget.checkoutToken,
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('checkout_token',
                              isEqualTo: widget.checkoutToken)
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

                          if (data['validated_checkout'] == true &&
                              !_hasNavigated) {
                            final userId = documentSnapshot.id;
                            _hasNavigated = true;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/receipt',
                                arguments: userId,
                              );
                            });
                          }

                          return Column(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.teal, size: 40),
                              SizedBox(height: 8),
                              Text('Checking out in progress...',
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
