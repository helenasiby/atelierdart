import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid) // Fetch orders for this seller
        .orderBy('orderDate', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Orders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buyer: ${order['buyerName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Product: ${order['itemName']}'),
                      Text('Price: \$${order['price']}'),
                      Text('Quantity: ${order['quantity']}'),
                      Text('Total: \$${order['total']}'),
                      const SizedBox(height: 8),
                      Text('Address: ${order['address']}'),
                      Text('Order Date: ${order['orderDate'].toDate()}'),
                      const SizedBox(height: 8),
                      Text('Status: ${order['status']}', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
