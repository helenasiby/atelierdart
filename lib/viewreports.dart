import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ViewAnalyticsPage extends StatefulWidget {
  const ViewAnalyticsPage({Key? key}) : super(key: key);

  @override
  _ViewAnalyticsPageState createState() => _ViewAnalyticsPageState();
}

class _ViewAnalyticsPageState extends State<ViewAnalyticsPage> {
  int totalUsers = 0;
  int totalOrders = 0;
  int totalProducts = 0;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Fetch total users
      final usersSnapshot = await firestore.collection('users').get();
      totalUsers = usersSnapshot.size;

      // Fetch total products
      final productsSnapshot = await firestore.collection('products').get();
      totalProducts = productsSnapshot.size;

      // Fetch total orders and calculate revenue
      final ordersSnapshot = await firestore.collection('orders').get();
      totalOrders = ordersSnapshot.size;

      totalRevenue = ordersSnapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['totalPrice'] ?? 0.0);
      });

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching analytics: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      ),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Total Users
              _buildAnalyticsCard(
                title: 'Total Users',
                value: totalUsers.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Total Products
              _buildAnalyticsCard(
                title: 'Total Products',
                value: totalProducts.toString(),
                icon: Icons.shopping_bag,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Total Orders
              _buildAnalyticsCard(
                title: 'Total Orders',
                value: totalOrders.toString(),
                icon: Icons.receipt,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Charts Section
              _buildBarChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview Chart",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _getBarGroups(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("Users",
                                  style: TextStyle(color: Colors.black));
                            case 1:
                              return const Text("Orders",
                                  style: TextStyle(color: Colors.black));
                            case 2:
                              return const Text("Products",
                                  style: TextStyle(color: Colors.black));
                            default:
                              return const Text("");
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: totalUsers.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: totalOrders.toDouble(),
            color: Colors.orange,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: totalProducts.toDouble(),
            color: Colors.green,
            width: 20,
          ),
        ],
      ),
    ];
  }
}
