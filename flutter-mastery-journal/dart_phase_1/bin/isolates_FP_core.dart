// Day 7 - Isolates, Functional Programming & Core Libraries

// 1. Isolates

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

void heavyComputationIsolate(List<dynamic> messages) {
  final SendPort replyPort = messages[0] as SendPort;
  final List<int> data = messages[1] as List<int>;

  // Simulates CPU-intensive work: bubble sort
  final sorted = [...data];
  for (int i = 0; i < sorted.length; i++) {
    for (int j = 0; j < sorted.length - i - 1; j++) {
      if (sorted[j] > sorted[j + 1]) {
        final temp = sorted[j + 1];
        sorted[j] = sorted[j + 1];
        sorted[j + 1] = temp;
      }
    }
  }

  replyPort.send(sorted);
}

Future<List<int>> sortInIsolate(List<int> data) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(heavyComputationIsolate, [receivePort.sendPort, data]);

  final result = await receivePort.first as List<int>;
  receivePort.close();
  return result;
}

// Functional programming
// Pure functions — same input, same output, no side effects
double discountedPrice(double price, double discountRate) =>
    price * (1 - discountRate);

// Higher-order functions
List<double> applyToAll(
  List<double> prices,
  double Function(double) transform,
) => prices.map(transform).toList();

// Closure — captures outer variable
double Function(double) createDiscounter(double rate) =>
    (price) => price * (1 - rate); // closes over 'rate'

// Function composition
typedef Transform<T> = T Function(T input);

Transform<T> compose<T>(Transform<T> f, Transform<T> g) =>
    (input) => f(g(input));

// Immutable data processing pipeline
typedef OrderStats = ({double total, double average, double max, int count});

OrderStats analyzeOrders(List<double> orders) {
  final validOrders = orders.where((o) => o > 0).toList();

  final total = validOrders.fold(0.0, (sum, o) => sum + o);
  final average = validOrders.isEmpty ? 0.0 : total / validOrders.length;
  final maximum = validOrders.isEmpty
      ? 0.0
      : validOrders.reduce((a, b) => a > b ? a : b);

  return (
    total: total,
    average: average,
    max: maximum,
    count: validOrders.length,
  );
}

// core libraries
void demonstrateConvert() {
  // JSON
  final user = {
    'name': 'Alice',
    'aged': 30,
    'tage': ['dart', 'flutter'],
  };
  final jsonString = jsonEncode(user);
  print(jsonString);
  print(jsonString.runtimeType);

  final decode = jsonDecode(jsonString) as Map<String, dynamic>;
  print(decode['tage']);
}

Future<void> demonstrateIO() async {
  // Write a file
  final file = File('output.txt');
  await file.writeAsString('Hello from dart:io!\nLine2\nLine3\n');

  // Reader
  final lines = await file.readAsLines();
  for (final line in lines) {
    print(line);
  }

  // Append to file
  final sink = file.openWrite(mode: FileMode.append);
  sink.writeln("Appended Line");
  await sink.flush();
  await sink.close();

  // Check existance and delete
  if (await file.exists()) await file.delete();
}

// JSON Parsing Practice
class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final bool inStock;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.inStock,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      inStock: json['in_stock'] as bool,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'in_stock': inStock,
    'tags': tags,
  };

  @override
  String toString() =>
      "Product($name, \$$price, tags:[$tags], category: $category - ${inStock ? "in stock" : "out of stock"})";
}

class ProductRepository {
  final List<Product> _products;
  const ProductRepository(this._products);

  factory ProductRepository.fromJsonString(String jsonString) {
    final data = jsonDecode(jsonString) as List<dynamic>;
    final products = data
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();

    return ProductRepository(products);
  }

  List<Product> get inStock =>
      _products.where((product) => product.inStock).toList();
  List<Product> get outOfStock =>
      _products.where((product) => !product.inStock).toList();

  List<Product> byCategory(String category) =>
      _products.where((product) => product.category == category).toList();

  Map<String, List<Product>> get groupedByCategory {
    final result = <String, List<Product>>{};
    for (final product in _products) {
      result.putIfAbsent(product.category, () => []).add(product);
    }
    return result;
  }

  double get avaragePrice =>
      _products.fold(0.0, (sum, product) => sum + product.price) /
      _products.length;

  List<Product> search(String query) => _products
      .where(
        (product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.tags.any((tag) => tag.contains(query.toLowerCase())),
      )
      .toList();
}

const sampleJson = '''
[
  {"id": 1, "name": "Laptop Pro",   "price": 1299.99, "category": "Electronics",
   "in_stock": true,  "tags": ["laptop", "apple", "m2"]},
  {"id": 2, "name": "Wireless Mouse","price": 29.99, "category": "Electronics",
   "in_stock": true,  "tags": ["mouse", "wireless", "logitech"]},
  {"id": 3, "name": "Running Shoes", "price": 89.99, "category": "Sports",
   "in_stock": false, "tags": ["shoes", "running", "nike"]},
  {"id": 4, "name": "Coffee Maker",  "price": 59.99, "category": "Kitchen",
   "in_stock": true,  "tags": ["coffee", "kitchen", "breville"]},
  {"id": 5, "name": "Python Book",   "price": 39.99, "category": "Books",
   "in_stock": true,  "tags": ["python", "programming", "book"]}
]
''';

void main() {
  final repo = ProductRepository.fromJsonString(sampleJson);

  print('=== All Products ===');
  for (final product in repo._products) {
    print("    $product");
  }

  print('\n=== Electronics ====');
  for (final p in repo.byCategory('Electronics')) {
    print('    $p');
  }

  print('\n === search: "wireless" ===');
  for (final p in repo.search('wireless')) {
    print('    $p');
  }

  print('\n === search: "programming" ===');
  for (final p in repo.search('programming')) {
    print('    $p');
  }

  print('\n=== By Category ===');
  repo.groupedByCategory.forEach((category, products) {
    print('  $category: ${products.map((p) => p.name).join(', ')}');
  });

  print('\nAvarage price: \$${repo.avaragePrice.toStringAsFixed(2)}');

  // serialize back to json
  final backToJson = jsonEncode(repo.inStock.map((p) => p.toJson()).toList());
  print('\nRe-serialized (first 80 chars): ${backToJson.substring(0, 80)}...');
}
