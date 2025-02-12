import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final String sellerId;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
    required this.sellerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orderId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: const Color(0xFF4A90E2),
        ),
        body: const Center(
          child: Text(
            'Error: Invalid order ID',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data?.data() as Map<String, dynamic>?;
          if (order == null) {
            return const Center(child: Text('No order details found'));
          }

          final sellerItems = _getSellerItems(order, sellerId);
          if (sellerItems.isEmpty) {
            return const Center(
                child: Text('No items from this seller in the order'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                _buildOrderDetails(order, sellerItems),
                const SizedBox(height: 24),
                const Text(
                  'Your Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: sellerItems.length,
                    itemBuilder: (_, i) => _buildOrderItem(sellerItems[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Filters order items by the `sellerId`
  List<Map<String, dynamic>> _getSellerItems(
      Map<String, dynamic> order, String sellerId) {
    final items = order['orderItems'];
    if (items == null || items is! List) return [];
    return items
        .where((item) =>
            item is Map<String, dynamic> && item['sellerId'] == sellerId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Builds the order details section
  Widget _buildOrderDetails(
      Map<String, dynamic> order, List<Map<String, dynamic>> sellerItems) {
    final total = sellerItems.fold(0.0, (t, item) {
      final price = item['price'];
      final quantity = item['quantity'] ?? 1;
      return price is num ? t + (price * quantity) : t;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order ID: ${order['orderId']}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          'Buyer: ${order['buyerDetails']['buyerName']}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          'Shipping: ${order['buyerDetails']['shippingAddress']}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          'Total: ₹$total',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          'Date: ${(order['orderDate'] as Timestamp).toDate().toString()}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          'Status: ${order['status']}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  /// Builds each individual order item
  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['productName'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹${item['price']}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              'Qty: ${item['quantity']}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
