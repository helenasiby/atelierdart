import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'productdetailspage.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('wishlist')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your wishlist is empty!"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final item = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(item['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => doc.reference.delete(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
