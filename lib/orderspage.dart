import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final String sellerId;

  const OrdersPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Current sellerId: $sellerId');

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/bg.jpeg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .orderBy('orderDate', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allOrders = snapshot.data?.docs ?? [];
                      print('Total orders found: ${allOrders.length}');

                      final sellerOrders = allOrders.where((doc) {
                        final orderData = doc.data() as Map<String, dynamic>;
                        final items = orderData['items'] as List?;

                        return items?.any((item) =>
                                item['sellerId'] == sellerId) ??
                            false;
                      }).toList();

                      print('Seller orders found: ${sellerOrders.length}');

                      if (sellerOrders.isEmpty) {
                        return const Center(
                          child: Text(
                            'No orders found for this seller',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: sellerOrders.length,
                        itemBuilder: (context, index) {
                          final orderDoc = sellerOrders[index];
                          final orderData =
                              orderDoc.data() as Map<String, dynamic>;
                          final items = (orderData['items'] as List?) ?? [];

                          // Filter items for current seller
                          final sellerItems = items.where((item) =>
                              item['sellerId'] == sellerId).toList();

                          // Fix: Fetch buyer details correctly from orderData
                          final buyerDetails = {
                            'buyerName': orderData['userName'] ?? 'Not Provided',
                            'buyerEmail': orderData['userEmail'] ?? 'Not Provided',
                            'shippingAddress': orderData['shippingAddress'] ?? 'Not Provided',
                          };

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              title: Text(
                                'Order ID: ${orderData['orderId'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (orderData['orderDate'] != null)
                                    Text(
                                      'Date: ${(orderData['orderDate'] as Timestamp).toDate().toString()}',
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  Text(
                                    'Status: ${orderData['status'] ?? 'Pending'}',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: const Text('Buyer Details'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Name: ${buyerDetails['buyerName']}'),
                                      Text('Email: ${buyerDetails['buyerEmail']}'),
                                      Text('Address: ${buyerDetails['shippingAddress']}'),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ...sellerItems.map<Widget>((item) {
                                  return ListTile(
                                    title: Text(
                                        item['productName'] ?? 'Unknown Product'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Price: ₹${item['price']?.toString() ?? '0'}'),
                                        Text(
                                            'Quantity: ${item['quantity']?.toString() ?? '1'}'),
                                        Text(
                                            'Product ID: ${item['productId'] ?? 'N/A'}'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => _updateOrderStatus(
                                          orderDoc.id, 'Approved'),
                                      child: const Text('Approve'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => _updateOrderStatus(
                                          orderDoc.id, 'Rejected'),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
      print('Order $orderId updated to $status');
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}
