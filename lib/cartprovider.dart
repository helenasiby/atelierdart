// cart_provider.dart
import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> item) {
    // Check if item already exists in cart
    final existingItemIndex = _items.indexWhere((i) => i['id'] == item['id']);
    
    if (existingItemIndex != -1) {
      // If item exists, increment quantity
      _items[existingItemIndex]['quantity'] = (_items[existingItemIndex]['quantity'] ?? 1) + 1;
    } else {
      // If item doesn't exist, add it with quantity 1
      _items.add({...item, 'quantity': 1});
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity > 0) {
      _items[index]['quantity'] = quantity;
      notifyListeners();
    } else {
      removeItem(index);
    }
  }

  int calculateTotal() {
    return _items.fold(0, (sum, item) => 
      sum + ((item['price'] as int) * (item['quantity'] as int)));
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }

  int get itemCount => _items.length;

  bool get isEmpty => _items.isEmpty;
}