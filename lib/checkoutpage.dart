import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'Credit Card';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _addressController.text = userDoc.data()?['address'] ?? '';
            _nameController.text = userDoc.data()?['name'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }

  bool _validatePaymentDetails() {
    switch (_selectedPaymentMethod) {
      case 'Credit Card':
        if (_cardNumberController.text.length != 16) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid card number')),
          );
          return false;
        }
        if (_cvvController.text.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid CVV')),
          );
          return false;
        }
        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(_expiryController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid expiry date format (MM/YY)')),
          );
          return false;
        }
        break;
      case 'UPI':
        if (!RegExp(r'^[a-zA-Z0-9.-]{2,256}@[a-zA-Z][a-zA-Z]{2,64}$')
            .hasMatch(_upiIdController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid UPI ID format')),
          );
          return false;
        }
        break;
    }
    return true;
  }

  int calculateTotal() {
    return widget.cartItems.fold(0, (sum, item) {
      final data = item.data() as Map<String, dynamic>;
      final price = data['price'] is String
          ? int.tryParse(data['price']) ?? 0
          : data['price'] as int;
      final quantity = data['quantity'] as int? ?? 1;
      return sum + (price * quantity);
    });
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate() || !_validatePaymentDetails()) return;

    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

      final orderItems = widget.cartItems.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'productId': doc.id,
          'productName': data['name'],
          'sellerId': data['sellerId'],
          'price': data['price'],
          'quantity': data['quantity'] ?? 1,
          'imagePath': data['imagePath'],
        };
      }).toList();

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': user.uid,
        'userEmail': user.email,
        'userName': _nameController.text,
        'shippingAddress': _addressController.text,
        'paymentMethod': _selectedPaymentMethod,
        'paymentDetails': {
          'method': _selectedPaymentMethod,
          'status': 'paid',
          'lastFourDigits': _selectedPaymentMethod == 'Credit Card'
              ? _cardNumberController.text.substring(_cardNumberController.text.length - 4)
              : null,
          'upiId': _selectedPaymentMethod == 'UPI' ? _upiIdController.text : null,
        },
        'items': orderItems,
        'totalAmount': calculateTotal(),
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
      });

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in widget.cartItems) {
        final cartItemRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(doc.id);
        batch.delete(cartItemRef);
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: ['Credit Card', 'UPI', 'Cash on Delivery']
              .map((method) => DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedPaymentMethod = value!);
          },
        ),
        const SizedBox(height: 16),
        if (_selectedPaymentMethod == 'Credit Card') ...[
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            maxLength: 16,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'Expiry (MM/YY)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
        if (_selectedPaymentMethod == 'UPI')
          TextFormField(
            controller: _upiIdController,
            decoration: InputDecoration(
              labelText: 'UPI ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              helperText: 'Enter your UPI ID (e.g., username@bankname)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter UPI ID';
              }
              return null;
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/bg.jpeg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Checkout',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // For balance
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = widget.cartItems[index].data() as Map<String, dynamic>;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Image.network(
                                    item['imagePath'] ?? '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                  title: Text(item['name'] ?? 'No Name'),
                                  subtitle: Text('Quantity: ${item['quantity'] ?? 1}'),
                                  trailing: Text(
                                    '₹${item['price']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${calculateTotal()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Delivery Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter delivery address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildPaymentSection(),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : placeOrder,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isProcessing
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Pay & Place Order',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
