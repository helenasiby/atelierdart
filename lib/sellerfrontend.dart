import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mainproject/finances.dart';
import 'package:mainproject/orderspage.dart';
import 'package:mainproject/profitpage.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'profilescreen.dart';
import 'login.dart';

class SellerHomePage extends StatefulWidget {
  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showOrders(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 7, 7, 7)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome, Seller!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(email ?? 'Loading...', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
            _buildDrawerItem(Icons.person, 'Profile', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            }),
            _buildDrawerItem(Icons.local_shipping, 'Orders & Shipping', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => OrdersPage(sellerId: FirebaseAuth.instance.currentUser?.uid ?? ''),
              ));
            }),
            _buildDrawerItem(Icons.monetization_on, 'Profit', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProfitPage(sellerId: FirebaseAuth.instance.currentUser?.uid ?? ''),
              ));
            }),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Back to Login', () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            }),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('images/bg.jpeg', fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildClickableStatCard(
                      context,
                      icon: Icons.receipt,
                      title: 'Orders',
                      color: const Color.fromARGB(255, 7, 7, 7),
                      onTap: () => _showOrders(context),
                    ),
                    _buildClickableStatCard(
                      context,
                      icon: Icons.attach_money,
                      title: 'Profit',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfitPage(sellerId: FirebaseAuth.instance.currentUser?.uid ?? ''),
                        ));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: _productsRef.where('email', isEqualTo: email).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found', style: TextStyle(fontSize: 16, color: Color(0xFF4A90E2))));
                    }
                    final products = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['imagePath'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              product['name'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '₹${product['price']}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => EditProductPage(
                                        productId: product.id,
                                        productData: product.data() as Map<String, dynamic>,
                                      ),
                                    ));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () {
                                    _deleteProduct(product.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete product: $e")),
      );
    }
  }

  void _showOrders(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => OrdersPage(
        sellerId: FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
    ));
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF333333))),
      onTap: onTap,
    );
  }

  Widget _buildClickableStatCard(BuildContext context,
      {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.2), child: Icon(icon, size: 26, color: color)),
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
