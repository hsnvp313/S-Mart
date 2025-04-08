import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'drawer.dart'; // ✅ Import the custom drawer

class CartSummaryScreen extends StatelessWidget {
  final String userId;
  CartSummaryScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Summary',
            style: GoogleFonts.fredoka(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomDrawer(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child:
                    Text('Your cart is empty', style: TextStyle(fontSize: 18)));
          }

          final cartData = snapshot.data!.data() as Map<String, dynamic>;
          final items = cartData['items'] as List<dynamic>;
          final totalCost = (cartData['total_cost'] as num).toDouble();
          final walletBalance =
              (cartData['wallet_balance'] as num?)?.toDouble() ?? 0.0;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // ✅ Two items per row
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75, // ✅ Adjust card height
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  item.containsKey('image_url') &&
                                          item['image_url'].isNotEmpty
                                      ? item['image_url']
                                      : 'https://via.placeholder.com/150', // ✅ Default placeholder if no image
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey);
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(item['product'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text(
                                      '${item['quantity']} ${item['unit'] ?? ''}',
                                      style: TextStyle(color: Colors.grey)),
                                  SizedBox(height: 4),
                                  Text(
                                    '₹${(item['price'] * (1 - item['discount'] / 100)).toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 18)),
                        Text('₹${totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Wallet Balance',
                            style: TextStyle(color: Colors.grey)),
                        Text('₹${walletBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: walletBalance >= totalCost
                                    ? Colors.green
                                    : Colors.red)),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: walletBalance >= totalCost
                              ? Colors.teal.shade600
                              : Colors.grey,
                        ),
                        onPressed: () {
                          if (walletBalance < totalCost) {
                            _showInsufficientBalanceDialog(context);
                          } else {
                            final checkoutToken = 'checkout:' +
                                userId +
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .set({'checkout_token': checkoutToken},
                                    SetOptions(merge: true));
                            Navigator.pushNamed(context, '/checkout',
                                arguments: checkoutToken);
                          }
                        },
                        child: Text('PROCEED TO CHECKOUT',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Insufficient Balance",
            style: TextStyle(color: Colors.teal.shade800)),
        content: Text(
            "Your wallet balance is too low for this purchase. Please top up your balance."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/wallet');
            },
            child:
                Text("TOP-UP", style: TextStyle(color: Colors.teal.shade800)),
          ),
        ],
      ),
    );
  }
}
