import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinancesPage extends StatefulWidget {
  @override
  _FinancesPageState createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final CollectionReference _ordersRef =
      FirebaseFirestore.instance.collection('orders');

  Future<Map<String, dynamic>> _fetchFinanceReport() async {
    double totalRevenue = 0;
    double totalExpenses = 0; // Placeholder if expenses are tracked
    int totalOrders = 0;

    final sellerId = FirebaseAuth.instance.currentUser?.uid;

    try {
      // Fetch all orders for the current seller
      QuerySnapshot ordersSnapshot = await _ordersRef
          .where('sellerId', isEqualTo: sellerId)
          .get();

      for (var doc in ordersSnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        totalRevenue += orderData['price'] ?? 0;
        totalOrders++;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalExpenses': totalExpenses,
        'totalOrders': totalOrders,
      };
    } catch (e) {
      print('Error fetching finance data: $e');
      return {
        'totalRevenue': 0.0,
        'totalExpenses': 0.0,
        'totalOrders': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchFinanceReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to fetch finance data. Please try again later.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            final financeData = snapshot.data!;
            final totalRevenue = financeData['totalRevenue'];
            final totalExpenses = financeData['totalExpenses'];
            final totalOrders = financeData['totalOrders'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Finance Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFinanceCard(
                    title: 'Total Revenue',
                    value: '₹${totalRevenue.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildFinanceCard(
                    title: 'Total Expenses',
                    value: '₹${totalExpenses.toStringAsFixed(2)}',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildFinanceCard(
                    title: 'Total Orders',
                    value: '$totalOrders',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Orders Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _ordersRef
                          .where('sellerId',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final orders = snapshot.data!.docs;

                        if (orders.isEmpty) {
                          return const Center(
                            child: Text(
                              'No orders found.',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index].data()
                                as Map<String, dynamic>;
                            return ListTile(
                              title: Text(
                                'Order ID: ${orders[index].id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Amount: ₹${order['price']}',
                              ),
                              trailing: Text(
                                (order['timestamp'] as Timestamp)
                                    .toDate()
                                    .toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
