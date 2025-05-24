import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final Map<String, int> _items = {};
  final Map<String, double> _prices = {};

  void addItem(String name, double price) {
    _items.update(name, (value) => value + 1, ifAbsent: () => 1);
    _prices[name] = price;
    notifyListeners();
  }

  double get totalPrice {
    return _items.entries
        .map((e) => _prices[e.key]! * e.value)
        .fold(0.0, (a, b) => a + b);
  }

  Map<String, int> get items => _items;

  void clear() {
    _items.clear();
    _prices.clear();
    notifyListeners();
  }
}
