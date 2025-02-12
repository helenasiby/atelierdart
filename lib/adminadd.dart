import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({Key? key}) : super(key: key);

  @override
  _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = 'admin1@gmail.com';
  String _password = 'admin@123';
  String _name = 'admin1';

  Future<void> _registerAdmin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Create user in Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Get the created user's UID
        String uid = userCredential.user!.uid;

        // Add admin details to Firestore
        await _firestore.collection('admins').doc(uid).set({
          'uid': uid,
          'email': _email,
          'name': _name,
          'role': 'admin', // To differentiate user roles
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Optionally, navigate to admin dashboard or login page
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Admin'),
        backgroundColor: const Color.fromARGB(255, 238, 140, 165),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) =>
                    value!.contains('@') ? null : 'Enter a valid email',
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.length >= 6 ? null : 'Password must be at least 6 characters',
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _registerAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 238, 140, 165),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Register Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
