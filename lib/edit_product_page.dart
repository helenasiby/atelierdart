import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductPage({
    Key? key,
    required this.productId,
    required this.productData,
  }) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.productData['name']);
    _priceController =
        TextEditingController(text: widget.productData['price'].toString());
    _descriptionController =
        TextEditingController(text: widget.productData['description'] ?? '');
  }

  void _updateProduct() async {
    final String name = _nameController.text.trim();
    final String priceText = _priceController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isNotEmpty && priceText.isNotEmpty && description.isNotEmpty) {
      try {
        final double price = double.parse(priceText);

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
          'name': name,
          'price': price,
          'description': description,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid number for the price.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Product Price',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Product Description',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProduct,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
