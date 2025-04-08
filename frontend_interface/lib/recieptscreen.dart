import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_name_heading.dart';

class ReceiptScreen extends StatefulWidget {
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _walletDeducted = false;

  Future<void> deductWalletBalance(String userId, double amount) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return;

    final transactions =
        List<Map<String, dynamic>>.from(userDoc['transactions'] ?? []);
    final data = userDoc.data() as Map<String, dynamic>;
    final walletBalance = (data['wallet_balance'] as num?)?.toDouble() ?? 0.0;

    double newBalance = walletBalance - amount;
    transactions.insert(0, {
      'amount': amount,
      'type': 'Purchase',
      'timestamp': DateTime.now().toIso8601String(),
      'items': data['items'],
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'wallet_balance': newBalance,
      'transactions': transactions,
      'items': FieldValue.delete(),
      'total_cost': FieldValue.delete(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text('No receipt data found.',
                    style: TextStyle(fontSize: 18)));
          }

          final cartData = snapshot.data!.data() as Map<String, dynamic>;
          final items = cartData['items'] as List<dynamic>? ?? [];
          final totalCost = (cartData['total_cost'] as num?)?.toDouble() ?? 0.0;

          if (!_walletDeducted) {
            _walletDeducted = true;
            deductWalletBalance(userId, totalCost);
          }

          return Column(
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
                      Icon(Icons.receipt, size: 40, color: Colors.white),
                      SizedBox(height: 8),
                      Text('Purchase Receipt',
                          style: TextStyle(color: Colors.white, fontSize: 22)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('S-mart',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800)),
                              SizedBox(height: 8),
                              Text('Thank you for shopping with us!',
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 16),
                              Divider(),
                              SizedBox(height: 16),
                              ...items
                                  .map((item) => Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(item['product'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                            Text(
                                                '₹${(item['price'] * (1 - item['discount'] / 100)).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              Divider(),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Paid:',
                                      style: TextStyle(fontSize: 18)),
                                  Text('₹${totalCost.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade800)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.teal.shade600,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'user': FieldValue.delete(),
                            'session_token': FieldValue.delete(),
                            'checkout_token': FieldValue.delete(),
                            'validated': FieldValue.delete(),
                            'validated_checkout': FieldValue.delete(),
                          });

                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text('DONE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
