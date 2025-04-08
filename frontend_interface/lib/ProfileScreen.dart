import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'drawer.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _profilePicture;
  String? _selectedGender;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots() // 🔥 Listen for changes in real-time
        .listen((userDoc) {
      if (userDoc.exists) {
        setState(() {
          _usernameController.text = userDoc['username'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _phoneController.text = userDoc['phone'] ?? '';
          _addressController.text = userDoc['address'] ?? '';
          _dobController.text = userDoc['dob'] ?? '';
          _selectedGender = userDoc['gender'] ?? null;
          _profilePicture =
              userDoc['profile_picture'] ?? ''; // ✅ Update in real-time
        });
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("❌ No image selected.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef =
          storageRef.child("profile_pictures/${widget.userId}.jpg");

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

      // ✅ Update Firestore with the new image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'profile_picture': downloadURL});

      // ✅ Update UI immediately
      setState(() {
        _profilePicture = downloadURL;
      });
    } catch (e) {
      print("❌ Error uploading image: $e");
    }
  }

// final picker = ImagePicker();
  // final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  // if (pickedFile != null) {
  //   final storageRef = FirebaseStorage.instance
  //       .ref()
  //       .child('profile_pictures')
  //       .child('${widget.userId}.jpg');

  //   await storageRef.putFile(File(pickedFile.path));
  //   final imageUrl = await storageRef.getDownloadURL();

  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.userId)
  //       .update({'profile_picture': imageUrl});

  //   setState(() {
  //     _profilePicture = imageUrl;
  //   });
  // }

  Future<void> _saveProfileChanges() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'username': _usernameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'dob': _dobController.text,
      'gender': _selectedGender,
    });

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _pickAndUploadImage();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profilePicture != null &&
                          _profilePicture!.isNotEmpty
                      ? NetworkImage(_profilePicture!) // ✅ Show uploaded image
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider, // ✅ Fallback image
                  child: _isEditing
                      ? Icon(Icons.edit, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_usernameController, 'Username'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_phoneController, 'Phone Number'),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_dobController, 'Date of Birth', isDate: true),
              _buildGenderDropdown(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isEditing) {
                    _saveProfileChanges();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: isDate && _isEditing
              ? IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: _selectedGender,
          onChanged: _isEditing
              ? (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              : null, // This makes it disabled when _isEditing is false
          items: ['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(labelText: 'Gender'),
        ));
  }
}
