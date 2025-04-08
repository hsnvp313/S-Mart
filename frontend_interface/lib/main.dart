import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ProfileScreen.dart';
import 'wallet.dart';
import 'signup_screen.dart';
import 'recieptscreen.dart';
import 'qrcode_screen.dart'; // Import QRCodeScreen
import 'checkout_screen.dart'; // Import CheckoutScreen
import 'cart_summary_screen.dart';
import 'app_name_heading.dart';
import 'drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('App started');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'S-Mart',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.light(
          primary: Colors.teal.shade800,
          secondary: Colors.tealAccent.shade400,
          surface: Colors
              .white, // Optional, you can remove it or set it to another property
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.teal.shade800,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(45),
            borderSide: const BorderSide(color: Colors.black, width: 2.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(45),
            borderSide: const BorderSide(color: Colors.black, width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(45),
            borderSide: const BorderSide(
              color: Colors.black, // Darker color when focused
              width: 2.5, // Slightly thicker when focused
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/qrcode': (context) {
          final sessionToken =
              ModalRoute.of(context)?.settings.arguments as String;
          return QRCodeScreen(sessionToken: sessionToken);
        },
        '/cartSummary': (context) => const HomeScreen(),
        '/checkout': (context) {
          final checkoutToken =
              ModalRoute.of(context)?.settings.arguments as String?;
          return CheckoutScreen(checkoutToken: checkoutToken ?? '');
        },
        '/receipt': (context) => ReceiptScreen(),
        '/wallet': (context) => WalletScreen(),
        '/profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return const LoginScreen(); // Redirect if not logged in
          }
          return ProfileScreen(userId: user.uid);
        },
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _title = "Cart Summary"; // Default page title
  int _selectedIndex = 0; // Index to track selected page

  // Function to handle page switching
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     switch (index) {
  //       case 0:
  //         _title = "Cart Summary";
  //         break;
  //       case 1:
  //         _title = "Order History";
  //         break;
  //       case 2:
  //         _title = "Wallet";
  //         break;
  //       case 3:
  //         _title = "Profile";
  //         break;
  //     }
  //     Navigator.pop(context); // Close the drawer when item is selected
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: AppNameWithPage(pageName: _title),
        centerTitle: true,
      ),
      // drawer: CustomDrawer(),
      //Drawer(
      //   child: StreamBuilder<DocumentSnapshot>(
      //     stream: FirebaseFirestore.instance
      //         .collection('users')
      //         .doc(userId)
      //         .snapshots(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return const Center(child: CircularProgressIndicator());
      //       } else if (snapshot.hasError ||
      //           !snapshot.hasData ||
      //           !snapshot.data!.exists) {
      //         return const Column(
      //           children: [
      //             UserAccountsDrawerHeader(
      //               accountName: Text("User Name"),
      //               accountEmail: Text("user@example.com"),
      //               currentAccountPicture: CircleAvatar(
      //                 child: Icon(Icons.person, size: 40),
      //               ),
      //             ),
      //             ListTile(
      //               title: Text('Error loading profile'),
      //               leading: Icon(Icons.error, color: Colors.red),
      //             ),
      //           ],
      //         );
      //       }

      //       final userData = snapshot.data!.data() as Map<String, dynamic>;
      //       final username = userData['username'] ?? 'User Name';
      //       final email = userData['email'] ?? 'user@example.com';
      //       final profilePicture = userData['profile_picture'];

      //       return Column(
      //         children: [
      //           UserAccountsDrawerHeader(
      //             accountName: Text(username),
      //             accountEmail: Text(email),
      //             currentAccountPicture: CircleAvatar(
      //               backgroundImage:
      //                   profilePicture != null && profilePicture.isNotEmpty
      //                       ? NetworkImage(profilePicture)
      //                       : const AssetImage('assets/default_profile.png')
      //                           as ImageProvider,
      //             ),
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.shopping_cart, color: Colors.teal),
      //             title: const Text('Cart Summary'),
      //             onTap: () => _onItemTapped(0),
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.history, color: Colors.teal),
      //             title: const Text('Order History'),
      //             onTap: () => _onItemTapped(1),
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.account_balance_wallet,
      //                 color: Colors.teal),
      //             title: const Text('Wallet'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.pushNamed(context, '/wallet');
      //             },
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.person, color: Colors.teal),
      //             title: const Text('Profile'),
      //             onTap: () => _onItemTapped(3),
      //           ),
      //           const Spacer(),
      //           ListTile(
      //             leading: const Icon(Icons.exit_to_app, color: Colors.red),
      //             title:
      //                 const Text('Logout', style: TextStyle(color: Colors.red)),
      //             onTap: () async {
      //               await FirebaseAuth.instance.signOut();
      //               Navigator.pushReplacementNamed(context, '/');
      //             },
      //           ),
      //           const SizedBox(height: 10),
      //         ],
      //       );
      //     },
      //   ),
      // ),
      body: _buildPage(_selectedIndex, userId),
    );
  }

  Widget _buildPage(int index, String userId) {
    switch (index) {
      case 0:
        return CartSummaryScreen(userId: userId);
      case 1:
        return const Center(child: Text("Order History (Coming Soon)"));
      case 2:
        return const Center(child: Text("Wallet (Coming Soon)"));
      case 3:
        return ProfileScreen(
            userId:
                FirebaseAuth.instance.currentUser!.uid); // Load Profile Screen
      default:
        return CartSummaryScreen(userId: userId);
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // Toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.teal.shade600,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.teal.shade600,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword; // Toggle password visibility
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword, // Use the toggle value
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );

                  final userId = userCredential.user!.uid;
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();

                  String sessionToken;

                  if (userDoc.exists &&
                      userDoc.data()!.containsKey('session_token')) {
                    sessionToken = userDoc['session_token'];
                  } else {
                    sessionToken = userId +
                        DateTime.now().millisecondsSinceEpoch.toString();
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .set({'session_token': sessionToken},
                            SetOptions(merge: true));
                  }

                  // ignore: use_build_context_synchronously
                  Navigator.pushNamed(context, '/qrcode',
                      arguments: sessionToken);
                } catch (e) {
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Login Failed'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Don’t have an account? Sign up here.'),
            ),
          ],
        ),
      ),
    );
  }
}
