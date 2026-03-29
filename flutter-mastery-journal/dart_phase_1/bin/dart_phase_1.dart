import 'package:path/path.dart';
// 🛒 Practice: Shopping Cart in Pure Dart

typedef ItemMap = Map<String, double>;

void main() {
  const double taxRate = 0.10;
  ItemMap availableProducts = {
    'Laptop': 1500.0,
    'Mouse': 25.0,
    'Keyboard': 50.0,
    'Monitor': 300.0,
  };

  late String shopName;
  shopName = "Dart Mart";

  Map<String, int> cart = {};

  // Arrow function to add items (Using Null-aware operators)
  var addToCart = (String itemName, [int qty = 1]) {
    if (!availableProducts.containsKey(itemName)) return;
    cart[itemName] = (cart[itemName] ?? 0) + qty;
    print("Added $qty x $itemName to cart.");
  };

  addToCart('Laptop');
  addToCart('Mouse', 2);
  addToCart('Monitor');
  addToCart('Keyboard');
  print('total in the cart: ${cart.entries}');

  var itemsToRemove = {'Keyboard', 'Webcam'};
  var currentItems = cart.keys.toSet();
  var remainingItems = currentItems.difference(itemsToRemove);
  print('current items: $currentItems');
  print('remaining items: $remainingItems');

  double subtotal = cart.entries.fold(0.0, (total, entry) {
    double price = availableProducts[entry.key] ?? 0.0;
    return total + (price * entry.value);
  });

  bool applyDiscount = subtotal > 1000;

  List<String> receiptLines = [
    "--- $shopName Receipt ---",
    for (var entry in cart.entries) "${entry.key} x${entry.value}",
    if (applyDiscount) "PROMO: 10% Discount Applied!",
    "Subtotal: \$${subtotal.toStringAsFixed(2)}",
    "Final Total (inc. tax): \$${(subtotal * (1 + taxRate)).toStringAsFixed(2)}",
  ];

  receiptLines.forEach(print);

  assert(subtotal >= 0, "Total cannot be negative");
}
