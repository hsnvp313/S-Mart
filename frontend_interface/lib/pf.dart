import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(child: ProfilePicture()),
    ),
  ));
}

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onProfileTapped(),
      child: Container(
        height: 100,
        width: 100,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            color: Colors.black,
            size: 35,
          ),
        ),
      ),
    );
  }

  Future<void> onProfileTapped() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("❌ No image selected.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("user_1.jpg");

      final imageBytes = await image.readAsBytes();
      UploadTask uploadTask = imageRef.putData(imageBytes);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((event) {
        print(
            "📡 Upload Progress: ${event.bytesTransferred}/${event.totalBytes}");
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      print("✅ Upload successful: $downloadURL");
    } catch (e) {
      print("❌ Error uploading image: $e");
    }
  }
}
