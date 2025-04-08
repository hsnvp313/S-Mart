import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_name_heading.dart';
import 'ProfileScreen.dart';
import 'drawer.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double walletBalance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  final TextEditingController _topUpController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  void _fetchWalletData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        walletBalance = (userDoc['wallet_balance'] ?? 0.0).toDouble();
        transactions =
            List<Map<String, dynamic>>.from(userDoc['transactions'] ?? []);
      });
    }
  }

  void _topUpWallet() async {
    double amount = double.tryParse(_topUpController.text) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);
    double newBalance = walletBalance + amount;
    transactions.insert(0, {
      'amount': amount,
      'type': 'Top-Up',
      'timestamp': DateTime.now().toIso8601String(),
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'wallet_balance': newBalance,
      'transactions': transactions,
    });

    setState(() {
      walletBalance = newBalance;
      _topUpController.clear();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet', style: GoogleFonts.fredoka(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
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
                  Icon(Icons.account_balance_wallet,
                      size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Smart Wallet',
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
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Available Balance',
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('₹${walletBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _topUpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter Amount',
                            labelStyle: GoogleFonts.nunito(color: Colors.grey),
                            prefixIcon: Icon(Icons.currency_rupee,
                                color: Colors.teal.shade600),
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isLoading ? null : _topUpWallet,
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text('ADD',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Transaction History',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8),
                  transactions.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('No transactions yet',
                              style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            var txn = transactions[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: txn['type'] == 'Top-Up'
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                    txn['type'] == 'Top-Up'
                                        ? Icons.add
                                        : Icons.remove,
                                    color: txn['type'] == 'Top-Up'
                                        ? Colors.green
                                        : Colors.red),
                              ),
                              title: Text(txn['type'],
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(txn['timestamp'].split('T')[0],
                                  style: TextStyle(color: Colors.grey)),
                              trailing: Text(
                                '₹${txn['amount'].toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: txn['type'] == 'Top-Up'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}
