import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mainproject/wishlist.dart';
import 'cartpage.dart';
import 'productdetailspage.dart';
import 'profilescreen.dart';
import 'wishlist.dart';

class BuyerPage extends StatefulWidget {
  const BuyerPage({Key? key}) : super(key: key);

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  final List<Map<String, dynamic>> cart = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> addToCart(Map<String, dynamic> product, String productId, String sellerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .set({
      ...product,
      'productId': productId,
      'sellerId': sellerId,
      'quantity': 1,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleWishlist(Map<String, dynamic> product, String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    final docSnapshot = await wishlistRef.doc(productId).get();

    if (docSnapshot.exists) {
      await wishlistRef.doc(productId).delete();
    } else {
      await wishlistRef.doc(productId).set({
        ...product,
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isInWishlist(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('products');
    
    // Modified search query to use name field instead of searchKeywords
    if (_searchQuery.isNotEmpty) {
      // Convert the search query to lowercase for case-insensitive search
      String searchLower = _searchQuery.toLowerCase();
      
      // Using whereGreaterThanOrEqualTo and whereLessThan for prefix matching
      return query
          .orderBy('name')
          .where('name', isGreaterThanOrEqualTo: searchLower)
          .where('name', isLessThan: searchLower + 'z');
    }
    return query;
  }

  void navigateToCart() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(cart: cart)));
  }

  void navigateToWishlist() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
  }

  void navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.black, size: 20),
                        onPressed: navigateToProfile,
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.black, size: 20),
                        onPressed: navigateToWishlist,
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.black, size: 20),
                        onPressed: navigateToCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  final products = snapshot.data!.docs;
                  return GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productData = product.data() as Map<String, dynamic>;
                      final productId = product.id;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                product: productData,
                                productId: productId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.network(
                                  productData['imagePath'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productData['name'] ?? 'No Name',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '₹${productData['price'] ?? '0'}',
                                      style: const TextStyle(fontSize: 11, color: Colors.black54)
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    StreamBuilder<bool>(
                                      stream: isInWishlist(productId),
                                      builder: (context, snapshot) {
                                        final isWishlisted = snapshot.data ?? false;
                                        return InkWell(
                                          onTap: () => toggleWishlist(productData, productId),
                                          child: Icon(
                                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                                            color: isWishlisted ? Colors.red : Colors.black54,
                                            size: 16,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 20,
                                      child: ElevatedButton(
                                        onPressed: () => addToCart(
                                          productData,
                                          productId,
                                          productData['sellerId']
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}