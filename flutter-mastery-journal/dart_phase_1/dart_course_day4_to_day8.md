# Dart 3 Structured Course — Days 4 through 8
> All code uses **Dart 3**, **Sound Null Safety**, and modern best practices.

---

# 📅 Day 4 — Control Flow, Functions & Collections

---

## 4.1 Control Flow — `if/else` and Ternary `? :`

### Concept

`if/else` evaluates a `bool` expression and branches execution. Dart enforces that the condition is always a `bool` — unlike C/Java, integers are **not** truthy.

The ternary `condition ? valueIfTrue : valueIfFalse` is for **single-expression choices**. For complex branching, prefer `if/else` for readability.

### Code Example

```dart
// if/else — delivery fee calculator
double deliveryFee(double orderTotal, bool isPremiumMember) {
  if (isPremiumMember) {
    return 0.0;
  } else if (orderTotal >= 50.0) {
    return 2.99;
  } else {
    return 5.99;
  }
}

// Ternary — concise label
String stockLabel(int quantity) =>
    quantity > 0 ? 'In Stock ($quantity left)' : 'Out of Stock';

void main() {
  print(deliveryFee(30.0, false));   // 5.99
  print(deliveryFee(60.0, false));   // 2.99
  print(deliveryFee(10.0, true));    // 0.0
  print(stockLabel(0));              // Out of Stock
  print(stockLabel(5));              // In Stock (5 left)
}
```

### Pitfalls

- `if (someInt)` → **compile error**. You must write `if (someInt != 0)`.
- Deep ternary nesting is legal but a code smell. If you have `a ? b ? c : d : e`, use `if/else`.

### Reference
[dart.dev — Branches](https://dart.dev/language/branches)

---

## 4.2 Control Flow — `switch/case` with Pattern Matching (Dart 3)

### Concept

Dart 3 completely overhauled `switch`. It now supports **pattern matching**, **guard clauses**, and can be used as an **expression** (returns a value). The compiler enforces exhaustiveness on sealed classes and enums.

### Code Example

```dart
sealed class Shape {}
class Circle extends Shape { final double radius; Circle(this.radius); }
class Rectangle extends Shape { final double width, height; Rectangle(this.width, this.height); }
class Triangle extends Shape { final double base, height; Triangle(this.base, this.height); }

// switch EXPRESSION — returns a value directly
double area(Shape shape) => switch (shape) {
  Circle(:final radius)            => 3.14159 * radius * radius,
  Rectangle(:final width, :final height) => width * height,
  Triangle(:final base, :final height)   => 0.5 * base * height,
};

// Guard clause with 'when'
String classify(int n) => switch (n) {
  0                  => 'zero',
  int x when x < 0  => 'negative',
  int x when x.isEven => 'positive even',
  _                  => 'positive odd',
};

void main() {
  print(area(Circle(5)));            // 78.53...
  print(area(Rectangle(4, 6)));      // 24.0
  print(classify(-3));               // negative
  print(classify(8));                // positive even
}
```

### Pitfalls

- Missing a case on a `sealed` class is a **compile error** (exhaustiveness check) — this is the feature, not a bug.
- The wildcard `_` matches anything; place it last or the compiler warns about unreachable cases.

### Reference
[dart.dev — Patterns](https://dart.dev/language/patterns)

---

## 4.3 Control Flow — `for`, `for-in`, `while`, `do-while`

### Concept

| Loop | Use when |
|---|---|
| `for (init; cond; step)` | Index needed |
| `for (var x in iterable)` | Values only, any `Iterable` |
| `while (cond)` | Count unknown; check **before** each iteration |
| `do { } while (cond)` | Must run **at least once**; check **after** |

`for-in` works on anything `Iterable` — `List`, `Set`, `Map.keys`, generators, etc.

### Code Example

```dart
// for — build multiplication table row
List<String> multiplicationRow(int n) => [
  for (int i = 1; i <= 10; i++) '$n × $i = ${n * i}',
];

// for-in — process a list of orders
void printOrderSummary(List<String> items) {
  for (final item in items) {
    print('→ $item');
  }
}

// while — retry until condition met
int findFirstEven(List<int> numbers) {
  int i = 0;
  while (i < numbers.length && numbers[i].isOdd) i++;
  return i < numbers.length ? numbers[i] : -1;
}

// do-while — must validate at least once
String getValidInput(List<String> inputs) {
  int attempt = 0;
  String input;
  do {
    input = inputs[attempt++];
  } while (input.isEmpty && attempt < inputs.length);
  return input;
}

void main() {
  print(multiplicationRow(7).sublist(0, 3));
  // [7 × 1 = 7, 7 × 2 = 14, 7 × 3 = 21]

  print(findFirstEven([3, 7, 9, 4, 6])); // 4
  print(getValidInput(['', '', 'hello'])); // hello
}
```

### Reference
[dart.dev — Loops](https://dart.dev/language/loops)

---

## 4.4 Control Flow — `break`, `continue`, Labelled Loops

### Concept

- **`break`** — exits the **nearest enclosing** loop or `switch`.
- **`continue`** — skips to the next iteration of the **nearest enclosing** loop.
- **Labels** — prefix a loop with `labelName:` then use `break labelName` / `continue labelName` to target an outer loop. Rare, but essential for nested search problems.

### Code Example

```dart
// break — early exit from search
int? findIndex(List<int> list, int target) {
  int? result;
  for (int i = 0; i < list.length; i++) {
    if (list[i] == target) {
      result = i;
      break; // no need to scan further
    }
  }
  return result;
}

// continue — skip processing invalid items
List<double> parsePrices(List<String> raw) {
  final prices = <double>[];
  for (final s in raw) {
    final cleaned = s.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) continue; // skip junk
    prices.add(double.parse(cleaned));
  }
  return prices;
}

// Labelled break — exit outer loop from inner loop
bool hasCommonElement(List<int> a, List<int> b) {
  bool found = false;
  outer:
  for (final x in a) {
    for (final y in b) {
      if (x == y) {
        found = true;
        break outer; // exits BOTH loops
      }
    }
  }
  return found;
}

void main() {
  print(findIndex([10, 30, 50, 70], 50)); // 2
  print(parsePrices(['\$12.99', 'N/A', '€8.50', ''])); // [12.99, 8.5]
  print(hasCommonElement([1, 3, 5], [2, 4, 5])); // true
}
```

### Reference
[dart.dev — Break and continue](https://dart.dev/language/loops#break-and-continue)

---

## 4.5 Control Flow — `assert`

### Concept

`assert(condition, 'optional message')` throws an `AssertionError` **only in debug mode** (removed entirely in production builds). It is the canonical way to document and verify developer-facing invariants — not for user-input validation.

### Code Example

```dart
class BankAccount {
  double _balance;

  BankAccount(double initialBalance)
      : assert(initialBalance >= 0, 'Initial balance cannot be negative'),
        _balance = initialBalance;

  void deposit(double amount) {
    assert(amount > 0, 'Deposit amount must be positive');
    _balance += amount;
  }

  void withdraw(double amount) {
    assert(amount > 0 && amount <= _balance,
        'Invalid withdrawal: amount=$amount, balance=$_balance');
    _balance -= amount;
  }

  double get balance => _balance;
}
```

### Pitfall

Never use `assert` to validate user input or network data — it is stripped in release builds. Use `if/throw` instead for runtime-critical validation.

### Reference
[dart.dev — Assert](https://dart.dev/language/error-handling#assert)

---

## 4.6 Functions — Named & Positional Parameters

### Concept

Dart has three parameter flavors:

| Type | Syntax | Required by default? |
|---|---|---|
| Positional required | `int age` | Yes |
| Positional optional | `[int age = 0]` | No |
| Named | `{required String name, int age = 0}` | Depends on `required` |

Named parameters are **opt-in required** via the `required` keyword. Named parameters improve call-site readability and are the Flutter standard.

### Code Example

```dart
// Named params — clear at call site
Widget buildButton({
  required String label,
  required VoidCallback onPressed,
  bool isLoading = false,
  Color color = const Color(0xFF2196F3),
}) {
  // ...
  return ElevatedButton(onPressed: isLoading ? null : onPressed, child: Text(label));
}

// Positional optional — for brief utility functions
String repeat(String s, [int times = 2, String separator = '']) =>
    List.filled(times, s).join(separator);

// Mixed: required positional + named optional
String formatName(String firstName, String lastName, {String? title}) {
  final prefix = title != null ? '$title ' : '';
  return '$prefix$firstName $lastName'.trim();
}

void main() {
  print(repeat('ha'));              // haha
  print(repeat('ha', 3, '-'));     // ha-ha-ha
  print(formatName('Jane', 'Doe', title: 'Dr.')); // Dr. Jane Doe
  print(formatName('John', 'Smith'));              // John Smith
}
```

### Reference
[dart.dev — Parameters](https://dart.dev/language/functions#parameters)

---

## 4.7 Functions — Arrow Functions `=>`

### Concept

`=> expression` is syntactic sugar for `{ return expression; }`. It signals that a function is **a single expression** — great for getters, callbacks, and short utility functions.

### Code Example

```dart
// Arrow function
double circleArea(double r) => 3.14159 * r * r;

// Arrow getter
class Product {
  final String name;
  final double price;
  final int quantity;

  const Product(this.name, this.price, this.quantity);

  double get totalValue => price * quantity;
  bool get isAvailable => quantity > 0;

  @override
  String toString() => 'Product($name, \$$price × $quantity)';
}

// Arrow with collection
List<double> taxedPrices(List<double> prices, double rate) =>
    prices.map((p) => p * (1 + rate)).toList();

void main() {
  final p = Product('Laptop', 999.99, 3);
  print(p.totalValue);  // 2999.97
  print(taxedPrices([10.0, 20.0, 30.0], 0.15)); // [11.5, 23.0, 34.5]
}
```

### Reference
[dart.dev — Functions](https://dart.dev/language/functions)

---

## 4.8 Functions — First-Class Functions, Anonymous Functions & `typedef`

### Concept

In Dart, functions are **first-class objects** — they can be stored in variables, passed as arguments, and returned from other functions. This enables powerful callback patterns and functional-style programming.

`typedef` creates a **named alias** for a function type, improving code readability and reuse.

### Code Example

```dart
// typedef — name the function signature once
typedef Validator<T> = String? Function(T value);
typedef Transformer<A, B> = B Function(A input);

// First-class function: passing a function as argument
List<T> filterList<T>(List<T> items, bool Function(T) predicate) =>
    items.where(predicate).toList();

// Anonymous function assigned to variable
final isExpensive = (double price) => price > 100.0;

// Higher-order function: returns a function
Validator<String> minLength(int min) =>
    (value) => value.length >= min ? null : 'Minimum $min characters required';

// Transformer usage
String applyTransformer<A, B>(A input, Transformer<A, B> transform) =>
    transform(input).toString();

void main() {
  final prices = [9.99, 149.0, 49.99, 299.0, 12.0];

  // Named function reference
  final expensive = filterList(prices, isExpensive);
  print(expensive); // [149.0, 299.0]

  // Anonymous function inline
  final cheap = filterList(prices, (p) => p < 20.0);
  print(cheap); // [9.99, 12.0]

  // Validator from factory function
  final validatePassword = minLength(8);
  print(validatePassword('abc'));         // Minimum 8 characters required
  print(validatePassword('securePass'));  // null (valid)

  // Transformer
  print(applyTransformer(42, (n) => 'Value: $n')); // Value: 42
}
```

### Reference
[dart.dev — Functions as first-class objects](https://dart.dev/language/functions#functions-as-first-class-objects)

---

## 4.9 Collections — List Deep Dive

### Concept

`List<T>` is Dart's ordered, index-based collection. The most important methods:

| Method | Purpose |
|---|---|
| `add` / `addAll` | Append one or multiple items |
| `where` | Filter — returns lazy `Iterable` |
| `map` | Transform each element |
| `reduce` | Combine into single value (throws on empty) |
| `fold` | Like reduce but with initial value (safe on empty) |
| `sort` | In-place sort with optional comparator |
| `contains` | Membership check |
| `any` / `every` | Existence / universal predicates |
| `firstWhere` | Find first match |

### Code Example

```dart
class Product {
  final String name;
  final double price;
  final String category;
  const Product(this.name, this.price, this.category);
}

void main() {
  final products = [
    Product('Laptop',   999.99, 'Electronics'),
    Product('T-Shirt',   19.99, 'Clothing'),
    Product('Phone',    699.99, 'Electronics'),
    Product('Jeans',     49.99, 'Clothing'),
    Product('Headphones',149.99,'Electronics'),
  ];

  // where — filter electronics
  final electronics = products.where((p) => p.category == 'Electronics').toList();
  print(electronics.length); // 3

  // map — extract names
  final names = products.map((p) => p.name).toList();
  print(names); // [Laptop, T-Shirt, Phone, Jeans, Headphones]

  // fold — total price (safe on empty list)
  final total = products.fold(0.0, (sum, p) => sum + p.price);
  print(total.toStringAsFixed(2)); // 1919.95

  // sort — by price descending
  final sorted = [...products]..sort((a, b) => b.price.compareTo(a.price));
  print(sorted.first.name); // Laptop

  // reduce — find most expensive (throws if list is empty!)
  final priciest = products.reduce((a, b) => a.price > b.price ? a : b);
  print(priciest.name); // Laptop

  // any / every
  print(products.any((p) => p.price > 900));   // true
  print(products.every((p) => p.price > 10));  // true
}
```

### Reference
[dart.dev — List](https://api.dart.dev/dart-core/List-class.html)

---

## 4.10 Collections — Map Deep Dive

### Concept

`Map<K, V>` is a key-value store. Keys are unique. Important methods:

| Method | Purpose |
|---|---|
| `entries` | Iterable of `MapEntry<K,V>` |
| `keys` / `values` | Iterables of keys or values |
| `putIfAbsent` | Add only if key missing |
| `update` | Modify existing value |
| `updateAll` | Transform all values |
| `removeWhere` | Delete matching entries |

### Code Example

```dart
void main() {
  // Build an inventory map
  final inventory = <String, int>{
    'apples': 50,
    'bananas': 30,
    'oranges': 20,
  };

  // putIfAbsent — add only if missing
  inventory.putIfAbsent('mangoes', () => 10);
  inventory.putIfAbsent('apples', () => 999); // won't overwrite
  print(inventory['apples']);  // 50
  print(inventory['mangoes']); // 10

  // update — modify existing
  inventory.update('bananas', (v) => v + 20);
  print(inventory['bananas']); // 50

  // entries — iterate key/value pairs
  final lowStock = inventory.entries
      .where((e) => e.value < 25)
      .map((e) => '${e.key}: ${e.value}')
      .toList();
  print(lowStock); // [oranges: 20]

  // Word frequency with putIfAbsent + update pattern
  final text = 'the quick brown fox jumps over the lazy fox';
  final freq = <String, int>{};
  for (final word in text.split(' ')) {
    freq.update(word, (v) => v + 1, ifAbsent: () => 1);
  }
  print(freq['fox']); // 2
  print(freq['the']); // 2
}
```

### Reference
[dart.dev — Map](https://api.dart.dev/dart-core/Map-class.html)

---

## 4.11 Collections — Set Deep Dive

### Concept

`Set<T>` guarantees **uniqueness**. It has O(1) lookup, unlike List's O(n). Key set operations: `union`, `intersection`, `difference`.

### Code Example

```dart
void main() {
  final setA = {1, 2, 3, 4, 5};
  final setB = {4, 5, 6, 7, 8};

  print(setA.union(setB));        // {1, 2, 3, 4, 5, 6, 7, 8}
  print(setA.intersection(setB)); // {4, 5}
  print(setA.difference(setB));   // {1, 2, 3}

  // Practical: deduplicate a list
  final withDupes = [1, 2, 2, 3, 3, 3, 4];
  final unique = withDupes.toSet().toList();
  print(unique); // [1, 2, 3, 4]

  // Tag system — find users with ALL required tags
  final userTags = {'dart', 'flutter', 'mobile', 'android'};
  final requiredTags = {'dart', 'flutter'};
  final hasAll = requiredTags.every(userTags.contains);
  print(hasAll); // true

  // Permission system
  final adminPerms  = {'read', 'write', 'delete', 'manage'};
  final editorPerms = {'read', 'write'};
  final extraPerms  = adminPerms.difference(editorPerms);
  print(extraPerms); // {delete, manage}
}
```

### Reference
[dart.dev — Set](https://api.dart.dev/dart-core/Set-class.html)

---

## 4.12 Collections — `collection if` and `collection for`

### Concept

Dart lets you embed **`if`** and **`for`** directly inside list/set/map literals. This is heavily used in Flutter widget trees and collection builders, enabling conditional and repeated elements without temporary variables.

### Code Example

```dart
Widget buildMenu({required bool isAdmin, required List<String> plugins}) {
  // Imagine these return widgets
  return Column(children: [
    ListTile(title: 'Home'),
    ListTile(title: 'Profile'),
    if (isAdmin) ListTile(title: 'Admin Dashboard'),  // collection if
    if (isAdmin) ListTile(title: 'User Management'),
    for (final plugin in plugins)                     // collection for
      ListTile(title: plugin),
  ]);
}

void main() {
  // Pure Dart examples
  final flags = [true, false, true];

  // Collection if
  final labels = [
    'always here',
    if (flags[0]) 'flag0 is true',
    if (flags[1]) 'flag1 is true', // omitted
  ];
  print(labels); // [always here, flag0 is true]

  // Collection for
  final numbers = [1, 2, 3];
  final doubled = [for (final n in numbers) n * 2];
  print(doubled); // [2, 4, 6]

  // Combined: build map from two lists
  final keys   = ['a', 'b', 'c'];
  final values = [1, 2, 3];
  final map = {
    for (int i = 0; i < keys.length; i++) keys[i]: values[i],
  };
  print(map); // {a: 1, b: 2, c: 3}
}
```

### Reference
[dart.dev — Collection operators](https://dart.dev/language/collections#control-flow-operators)

---

## 4.13 Day 4 Practice — Shopping Cart

Build a complete shopping cart in pure Dart using everything from Day 4.

```dart
// models.dart
class CartItem {
  final String id;
  final String name;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
  }) : assert(unitPrice >= 0), assert(quantity > 0);

  double get subtotal => unitPrice * quantity;

  @override
  String toString() => '$name x$quantity @ \$${unitPrice.toStringAsFixed(2)}';
}

// cart.dart
class ShoppingCart {
  final Map<String, CartItem> _items = {};
  final double taxRate;

  ShoppingCart({this.taxRate = 0.08});

  void addItem(CartItem item) {
    _items.update(
      item.id,
      (existing) {
        existing.quantity += item.quantity;
        return existing;
      },
      ifAbsent: () => item,
    );
  }

  void removeItem(String id) => _items.remove(id);

  void updateQuantity(String id, int quantity) {
    assert(quantity > 0, 'Quantity must be positive');
    if (_items.containsKey(id)) {
      _items[id]!.quantity = quantity;
    }
  }

  List<CartItem> get items => _items.values.toList();

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  void printReceipt() {
    if (isEmpty) { print('Cart is empty.'); return; }
    print('===== RECEIPT =====');
    for (final item in items) {
      print('  $item  =  \$${item.subtotal.toStringAsFixed(2)}');
    }
    print('-------------------');
    print('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    print('Tax (${(taxRate * 100).toStringAsFixed(0)}%): \$${tax.toStringAsFixed(2)}');
    print('TOTAL:    \$${total.toStringAsFixed(2)}');
    print('===================');
  }
}

// main.dart
void main() {
  final cart = ShoppingCart(taxRate: 0.10);

  cart.addItem(CartItem(id: 'p1', name: 'Laptop',   unitPrice: 999.99));
  cart.addItem(CartItem(id: 'p2', name: 'Mouse',    unitPrice: 29.99, quantity: 2));
  cart.addItem(CartItem(id: 'p3', name: 'USB-C Hub',unitPrice: 49.99));

  // Add more of an existing item
  cart.addItem(CartItem(id: 'p2', name: 'Mouse', unitPrice: 29.99));
  // Mouse quantity is now 3

  cart.removeItem('p3');
  cart.printReceipt();

  // Summary using collection operations
  final expensiveItems = cart.items.where((i) => i.unitPrice > 50).toList();
  print('\nHigh-value items: ${expensiveItems.map((i) => i.name).join(', ')}');
  print('Total items in cart: ${cart.itemCount}');
}
```

**Expected output:**
```
===== RECEIPT =====
  Laptop x1 @ $999.99  =  $999.99
  Mouse x3 @ $29.99  =  $89.97
-------------------
Subtotal: $1089.96
Tax (10%): $108.996
TOTAL:    $1198.956
===================

High-value items: Laptop
Total items in cart: 4
```

---

# 📅 Day 5 — OOP in Dart

---

## 5.1 Classes & Objects — Constructors

### Concept

Dart supports four constructor types:

| Type | Purpose |
|---|---|
| **Default** | Standard `ClassName(params)` |
| **Named** | `ClassName.name(params)` — multiple constructors |
| **Factory** | Returns an instance (can return cached/subtype) |
| **Const** | Compile-time constant; requires all fields `final` |

**Initializer list** (`:`): runs before the constructor body, used for `final` field assignment and `super()` calls.

### Code Example

```dart
class Temperature {
  final double celsius;

  // Default constructor with initializer list
  Temperature(this.celsius) : assert(celsius >= -273.15, 'Below absolute zero!');

  // Named constructors
  Temperature.fromFahrenheit(double f) : celsius = (f - 32) * 5 / 9;
  Temperature.fromKelvin(double k) : celsius = k - 273.15;
  const Temperature.absoluteZero() : celsius = -273.15;

  // Factory — caching pattern
  static final Map<double, Temperature> _cache = {};
  factory Temperature.cached(double celsius) {
    return _cache.putIfAbsent(celsius, () => Temperature(celsius));
  }

  double get fahrenheit => celsius * 9 / 5 + 32;
  double get kelvin     => celsius + 273.15;

  @override
  String toString() => '${celsius.toStringAsFixed(1)}°C';
}

void main() {
  final boiling  = Temperature(100);
  final freezing = Temperature.fromFahrenheit(32);
  final abs      = Temperature.absoluteZero();

  print(boiling);            // 100.0°C
  print(freezing);           // 0.0°C
  print(boiling.fahrenheit); // 212.0
  print(abs.celsius);        // -273.15

  // Const objects are identical
  const a = Temperature.absoluteZero();
  const b = Temperature.absoluteZero();
  print(identical(a, b)); // true
}
```

---

## 5.2 Classes & Objects — Getters, Setters & Static Members

### Code Example

```dart
class Circle {
  // Private mutable field
  double _radius;

  static const double pi = 3.14159265358979;
  static int _instanceCount = 0;

  Circle(double radius)
      : _radius = radius,
        assert(radius > 0) {
    _instanceCount++;
  }

  // Getter
  double get radius => _radius;
  double get area => pi * _radius * _radius;
  double get circumference => 2 * pi * _radius;

  // Setter with validation
  set radius(double value) {
    if (value <= 0) throw ArgumentError('Radius must be positive');
    _radius = value;
  }

  // Static member — class-level, not per-instance
  static int get instanceCount => _instanceCount;

  @override
  String toString() => 'Circle(r=$_radius, area=${area.toStringAsFixed(2)})';
}

void main() {
  final c1 = Circle(5);
  final c2 = Circle(10);

  print(c1.area.toStringAsFixed(2)); // 78.54
  c1.radius = 7;
  print(c1); // Circle(r=7.0, area=153.94)

  print(Circle.instanceCount); // 2
  print(Circle.pi);            // 3.14159265358979
}
```

### Reference
[dart.dev — Classes](https://dart.dev/language/classes)

---

## 5.3 Inheritance & Polymorphism — `extends`, `super`, Overriding

### Concept

Dart uses **single inheritance** via `extends`. Override methods with `@override`. Call the parent via `super`. Dart supports **covariant returns** and you can override getters too.

### Code Example

```dart
abstract class Animal {
  final String name;
  Animal(this.name);

  // Abstract method — subclass MUST override
  String makeSound();

  // Concrete method — subclass CAN override
  String describe() => '$name says: ${makeSound()}';
}

class Dog extends Animal {
  final String breed;
  Dog(super.name, this.breed);

  @override
  String makeSound() => 'Woof!';

  @override
  String describe() => '${super.describe()} [Breed: $breed]';
}

class Cat extends Animal {
  Cat(super.name);

  @override
  String makeSound() => 'Meow!';
}

// Polymorphism
void introduceAnimal(Animal a) => print(a.describe());

void main() {
  final animals = <Animal>[
    Dog('Rex', 'German Shepherd'),
    Cat('Whiskers'),
    Dog('Buddy', 'Labrador'),
  ];

  for (final animal in animals) {
    introduceAnimal(animal); // runtime dispatch
  }
}
```

**Output:**
```
Rex says: Woof! [Breed: German Shepherd]
Whiskers says: Meow!
Buddy says: Woof! [Breed: Labrador]
```

---

## 5.4 OOP — `abstract` Classes, `implements`, `mixin`

### Concept

| Keyword | Meaning |
|---|---|
| `abstract class` | Can't be instantiated; may have abstract + concrete members |
| `implements` | Fulfil an interface contract; re-implement **all** members |
| `mixin` | Share behaviour across **unrelated** class hierarchies without full inheritance |
| `with` | Apply one or more mixins to a class |

Prefer `mixin` over inheritance for **orthogonal capabilities** (e.g., `Serializable`, `Loggable`, `Cacheable`).

### Code Example

```dart
// Interface via abstract class
abstract class Serializable {
  Map<String, dynamic> toJson();
}

abstract class Validatable {
  List<String> validate();
  bool get isValid => validate().isEmpty;
}

// Mixin — reusable logging behaviour
mixin Loggable {
  final List<String> _log = [];

  void log(String message) {
    _log.add('[${DateTime.now()}] $message');
  }

  List<String> get logs => List.unmodifiable(_log);
}

// Concrete class using all three
class UserProfile with Loggable implements Serializable, Validatable {
  String name;
  String email;
  int age;

  UserProfile({required this.name, required this.email, required this.age});

  @override
  Map<String, dynamic> toJson() => {
    'name': name, 'email': email, 'age': age,
  };

  @override
  List<String> validate() {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Name is required');
    if (!email.contains('@')) errors.add('Invalid email');
    if (age < 0 || age > 150) errors.add('Invalid age');
    return errors;
  }

  void update(String newName) {
    log('Name changed from $name to $newName');
    name = newName;
  }
}

void main() {
  final user = UserProfile(name: 'Alice', email: 'alice@example.com', age: 30);
  user.update('Alicia');

  print(user.isValid);    // true
  print(user.toJson());   // {name: Alicia, email: alice@example.com, age: 30}
  print(user.logs.first); // [timestamp] Name changed from Alice to Alicia

  // Invalid user
  final bad = UserProfile(name: '', email: 'notanemail', age: -5);
  print(bad.validate()); // [Name is required, Invalid email, Invalid age]
}
```

### Reference
[dart.dev — Mixins](https://dart.dev/language/mixins)

---

## 5.5 OOP — `sealed` Classes (Dart 3)

### Concept

A `sealed` class is like an `abstract` class but the compiler knows **all possible subtypes** (they must be in the same file). This enables **exhaustive pattern matching** — the compiler errors if you miss a case in a `switch`.

This is the Dart equivalent of Kotlin `sealed class` or Rust `enum`.

### Code Example

```dart
// All subtypes must be in the same file
sealed class NetworkResult<T> {}

class Success<T> extends NetworkResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends NetworkResult<T> {
  final String message;
  final int statusCode;
  const Failure(this.message, this.statusCode);
}

class Loading<T> extends NetworkResult<T> {
  const Loading();
}

// Exhaustive switch — compiler error if you miss a case
String handleResult(NetworkResult<String> result) => switch (result) {
  Success(:final data)                          => 'Got: $data',
  Failure(:final message, :final statusCode)    => 'Error $statusCode: $message',
  Loading()                                     => 'Loading...',
};

void main() {
  final results = <NetworkResult<String>>[
    Success('Hello, World!'),
    Failure('Not Found', 404),
    Loading(),
  ];

  for (final r in results) {
    print(handleResult(r));
  }
}
```

### Reference
[dart.dev — Sealed classes](https://dart.dev/language/class-modifiers#sealed)

---

## 5.6 Advanced OOP — Enhanced Enums

### Concept

Dart 3 enums can have **fields, constructors, and methods** — making them full-featured value types.

### Code Example

```dart
enum Priority {
  low(label: 'Low', weight: 1, color: 0xFF4CAF50),
  medium(label: 'Medium', weight: 2, color: 0xFFFF9800),
  high(label: 'High', weight: 3, color: 0xFFF44336),
  critical(label: 'Critical', weight: 4, color: 0xFF9C27B0);

  const Priority({
    required this.label,
    required this.weight,
    required this.color,
  });

  final String label;
  final int weight;
  final int color;

  bool get isUrgent => weight >= 3;

  static Priority fromWeight(int w) =>
      values.firstWhere((p) => p.weight == w,
          orElse: () => throw ArgumentError('Unknown weight: $w'));
}

void main() {
  final task = Priority.high;
  print(task.label);    // High
  print(task.isUrgent); // true

  final sorted = Priority.values.toList()
    ..sort((a, b) => b.weight.compareTo(a.weight));
  print(sorted.map((p) => p.label)); // (Critical, High, Medium, Low)
}
```

---

## 5.7 Advanced OOP — Extension Methods & Generics

### Code Example

```dart
// Extension methods — add methods to existing types without subclassing
extension StringExtensions on String {
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  bool get isValidEmail => RegExp(r'^[\w.]+@[\w]+\.\w+$').hasMatch(this);

  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}

// Generic stack with bounded type
class SortedList<T extends Comparable<T>> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
    _items.sort();
  }

  T get min => _items.first;
  T get max => _items.last;
  List<T> get items => List.unmodifiable(_items);
}

void main() {
  print('hello world'.titleCase);       // Hello World
  print('user@example.com'.isValidEmail); // true
  print('A very long string'.truncate(10)); // A very lon…

  final scores = SortedList<int>();
  scores.add(45);
  scores.add(92);
  scores.add(67);
  print(scores.items); // [45, 67, 92]
  print('Min: ${scores.min}, Max: ${scores.max}'); // Min: 45, Max: 92
}
```

### Reference
[dart.dev — Extension methods](https://dart.dev/language/extension-methods)

---

## 5.8 Day 5 Practice — BankAccount Hierarchy

```dart
// Mixin for transaction tracking
mixin Transactable {
  final List<String> _transactions = [];

  void _recordTransaction(String type, double amount, double balanceAfter) {
    _transactions.add(
        '[$type] \$${amount.toStringAsFixed(2)} → Balance: \$${balanceAfter.toStringAsFixed(2)}');
  }

  List<String> get transactionHistory => List.unmodifiable(_transactions);

  void printStatement() {
    print('--- Transaction History ---');
    for (final t in _transactions) print('  $t');
    print('--------------------------');
  }
}

// Base abstract class
abstract class Account with Transactable {
  final String accountNumber;
  final String holderName;
  double _balance;

  Account({
    required this.accountNumber,
    required this.holderName,
    required double initialBalance,
  })  : assert(initialBalance >= 0),
        _balance = initialBalance;

  double get balance => _balance;

  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit must be positive');
    _balance += amount;
    _recordTransaction('DEPOSIT', amount, _balance);
  }

  // Abstract — subclasses define withdrawal rules
  void withdraw(double amount);

  @override
  String toString() =>
      '${runtimeType}[$accountNumber] - $holderName: \$${_balance.toStringAsFixed(2)}';
}

// Savings account — minimum balance enforced
class SavingsAccount extends Account {
  final double minimumBalance;
  final double interestRate;

  SavingsAccount({
    required super.accountNumber,
    required super.holderName,
    required super.initialBalance,
    this.minimumBalance = 100.0,
    this.interestRate = 0.035,
  });

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    if (_balance - amount < minimumBalance) {
      throw StateError(
          'Cannot go below minimum balance of \$$minimumBalance');
    }
    _balance -= amount;
    _recordTransaction('WITHDRAWAL', amount, _balance);
  }

  void applyInterest() {
    final interest = _balance * interestRate;
    deposit(interest);
    _recordTransaction('INTEREST', interest, _balance);
  }
}

// Checking account — overdraft limit
class CheckingAccount extends Account {
  final double overdraftLimit;

  CheckingAccount({
    required super.accountNumber,
    required super.holderName,
    required super.initialBalance,
    this.overdraftLimit = 500.0,
  });

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    if (_balance - amount < -overdraftLimit) {
      throw StateError('Exceeds overdraft limit of \$$overdraftLimit');
    }
    _balance -= amount;
    _recordTransaction('WITHDRAWAL', amount, _balance);
  }
}

void main() {
  final savings = SavingsAccount(
    accountNumber: 'SAV-001',
    holderName: 'Alice',
    initialBalance: 1000.0,
  );

  final checking = CheckingAccount(
    accountNumber: 'CHK-001',
    holderName: 'Bob',
    initialBalance: 500.0,
    overdraftLimit: 200.0,
  );

  savings.deposit(500);
  savings.withdraw(200);
  savings.applyInterest();

  checking.deposit(100);
  checking.withdraw(750); // uses overdraft

  print(savings);
  savings.printStatement();

  print(checking);
  checking.printStatement();

  // Polymorphic list
  final accounts = <Account>[savings, checking];
  final totalAssets = accounts.fold(0.0, (sum, a) => sum + a.balance);
  print('\nTotal assets: \$${totalAssets.toStringAsFixed(2)}');
}
```

---

# 📅 Day 6 — Async Programming (Futures & Streams)

---

## 6.1 The Event Loop & `Future<T>`

### Concept

Dart is **single-threaded** but non-blocking. It runs an **event loop** with two queues:
1. **Microtask queue** — high priority (`.then()`, `Future.microtask`)
2. **Event queue** — lower priority (I/O, timers, user input)

A `Future<T>` represents a value that will be available *eventually*. It can be in one of three states: **uncompleted**, **completed with value**, or **completed with error**.

### Code Example

```dart
import 'dart:async';

// Simulating async operations
Future<String> fetchUserName(int id) async {
  await Future.delayed(Duration(milliseconds: 100)); // simulate network
  if (id <= 0) throw ArgumentError('Invalid user ID');
  return 'User_$id';
}

Future<double> fetchAccountBalance(String userName) =>
    Future.delayed(Duration(milliseconds: 50), () => 1250.75);

// async/await — reads like synchronous code
Future<void> showUserDashboard(int userId) async {
  try {
    final name    = await fetchUserName(userId);
    final balance = await fetchAccountBalance(name);
    print('Welcome $name! Balance: \$${balance.toStringAsFixed(2)}');
  } on ArgumentError catch (e) {
    print('Invalid input: $e');
  }
}

// Future.wait — parallel execution (faster than sequential await)
Future<void> loadDashboardData() async {
  print('Starting parallel fetch...');
  final stopwatch = Stopwatch()..start();

  final results = await Future.wait([
    fetchUserName(1),
    fetchUserName(2),
    fetchUserName(3),
  ]);

  stopwatch.stop();
  print('Fetched: $results in ${stopwatch.elapsedMilliseconds}ms');
  // ~100ms, not 300ms
}

void main() async {
  await showUserDashboard(42);
  await showUserDashboard(-1);
  await loadDashboardData();
}
```

---

## 6.2 Future Chaining — `.then()`, `.catchError()`, `.whenComplete()`

### Concept

The callback-style (pre-async/await) is still valid and sometimes cleaner for simple chains. Understanding it also helps when working with third-party APIs.

### Code Example

```dart
import 'dart:async';

Future<String> fetchData() =>
    Future.delayed(Duration(milliseconds: 200), () => '{"status":"ok","value":42}');

Future<String> processData(String raw) =>
    Future.value(raw.toUpperCase());

void runWithCallbacks() {
  fetchData()
    .then((raw) => processData(raw))
    .then((processed) => print('Result: $processed'))
    .catchError((e) => print('Error: $e'))
    .whenComplete(() => print('Fetch complete (always runs)'));
}

// Future.value / Future.error — wrap synchronous values
Future<int> divide(int a, int b) {
  if (b == 0) return Future.error(ArgumentError('Division by zero'));
  return Future.value(a ~/ b);
}

void main() async {
  runWithCallbacks();
  await Future.delayed(Duration(milliseconds: 500));

  final result = await divide(10, 2).catchError((_) => -1);
  print(result); // 5

  final bad = await divide(10, 0).catchError((_) => -1);
  print(bad);    // -1
}
```

---

## 6.3 Streams

### Concept

A `Stream<T>` is an **asynchronous sequence** of values over time — think of it as a `Future` that can emit multiple values.

| | Future | Stream |
|---|---|---|
| Values | One | Zero or many |
| Consumption | `await` | `await for`, `.listen()` |
| Error | One error | Errors at any point |

**Single-subscription**: one listener; used for HTTP responses, file reads.  
**Broadcast**: multiple listeners; used for UI events, websockets.

### Code Example

```dart
import 'dart:async';

// 1. Stream from generator (async*)
Stream<int> countdown(int from) async* {
  for (int i = from; i >= 0; i--) {
    await Future.delayed(Duration(milliseconds: 100));
    yield i;
  }
}

// 2. StreamController — manual emit
Stream<String> tickerStream() {
  final controller = StreamController<String>();
  int tick = 0;
  Timer.periodic(Duration(milliseconds: 200), (timer) {
    controller.add('Tick ${++tick}');
    if (tick >= 5) {
      timer.cancel();
      controller.close();
    }
  });
  return controller.stream;
}

// 3. Broadcast stream — multiple listeners
Stream<int> broadcastNumbers() =>
    Stream.periodic(Duration(milliseconds: 100), (i) => i).asBroadcastStream();

// 4. Stream transformers
Future<void> demonstrateTransformers() async {
  final numbers = Stream.fromIterable(List.generate(20, (i) => i));

  // Chain transformers
  final result = await numbers
      .where((n) => n.isEven)       // keep evens: 0,2,4,...18
      .map((n) => n * n)            // square: 0,4,16,...324
      .take(5)                      // first 5: 0,4,16,36,64
      .toList();

  print(result); // [0, 4, 16, 36, 64]
}

void main() async {
  // await for loop
  await for (final val in countdown(5)) {
    process('  $val...');
  }
  print('🚀 Blast off!');

  await demonstrateTransformers();

  // listen with error and done handlers
  tickerStream().listen(
    (event) => print(event),
    onError: (e) => print('Stream error: $e'),
    onDone: () => print('Stream closed.'),
  );

  await Future.delayed(Duration(seconds: 2));
}

void process(String s) => print(s);
```

---

## 6.4 Error Handling in Async Code

### Concept

Use `try/catch/finally` inside `async` functions — it behaves exactly like synchronous code. Use **typed catches** (`on ExceptionType`) to handle specific errors without swallowing everything.

### Code Example

```dart
// Custom exceptions
class NetworkException implements Exception {
  final int statusCode;
  final String message;
  const NetworkException(this.statusCode, this.message);

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

class ParseException implements Exception {
  final String field;
  const ParseException(this.field);

  @override
  String toString() => 'ParseException: failed to parse field "$field"';
}

// Async function with typed catches
Future<Map<String, dynamic>> fetchAndParse(String url) async {
  // Simulate various failure modes
  if (url.isEmpty)       throw ArgumentError('URL cannot be empty');
  if (url.contains('404')) throw NetworkException(404, 'Not Found');
  if (url.contains('bad'))  throw ParseException('id');

  await Future.delayed(Duration(milliseconds: 100));
  return {'id': 1, 'data': 'success'};
}

Future<void> loadResource(String url) async {
  try {
    final data = await fetchAndParse(url);
    print('Loaded: $data');
  } on ArgumentError catch (e) {
    print('Bad argument: $e');
  } on NetworkException catch (e) {
    print('Network failed: $e');
    // Could retry, show fallback UI, etc.
  } on ParseException catch (e) {
    print('Malformed response: $e');
  } catch (e, stackTrace) {
    // Catch-all for unexpected errors
    print('Unexpected error: $e');
    print(stackTrace);
  } finally {
    print('Cleanup for: $url');
  }
}

void main() async {
  await loadResource('https://api.example.com/users/1');
  await loadResource('https://api.example.com/404');
  await loadResource('bad-url');
  await loadResource('');
}
```

### Reference
[dart.dev — Error handling](https://dart.dev/language/error-handling)

---

## 6.5 Day 6 Practice — Download Progress Tracker

```dart
import 'dart:async';

class DownloadException implements Exception {
  final String reason;
  DownloadException(this.reason);
  @override String toString() => 'DownloadException: $reason';
}

class DownloadProgress {
  final String fileName;
  final int bytesDownloaded;
  final int totalBytes;

  const DownloadProgress({
    required this.fileName,
    required this.bytesDownloaded,
    required this.totalBytes,
  });

  double get percentage => (bytesDownloaded / totalBytes) * 100;
  bool get isComplete => bytesDownloaded >= totalBytes;

  String get progressBar {
    final filled = (percentage / 5).round();
    final bar = '█' * filled + '░' * (20 - filled);
    return '[$bar] ${percentage.toStringAsFixed(1)}%';
  }

  @override
  String toString() =>
      '$fileName: $progressBar (${bytesDownloaded ~/ 1024}/${totalBytes ~/ 1024} KB)';
}

// Simulates a file download as a Stream of progress updates
Stream<DownloadProgress> downloadFile({
  required String fileName,
  required int totalBytes,
  int chunkSize = 51200, // 50 KB per tick
  bool simulateError = false,
}) async* {
  int downloaded = 0;
  int tick = 0;

  while (downloaded < totalBytes) {
    await Future.delayed(Duration(milliseconds: 150));

    // Simulate random network failure
    if (simulateError && tick == 3) {
      throw DownloadException('Connection reset after 3 chunks');
    }

    downloaded = (downloaded + chunkSize).clamp(0, totalBytes);
    yield DownloadProgress(
      fileName: fileName,
      bytesDownloaded: downloaded,
      totalBytes: totalBytes,
    );
    tick++;
  }
}

Future<void> runDownload(String fileName, int size,
    {bool simulateError = false}) async {
  print('\nStarting download: $fileName');
  try {
    await for (final progress in downloadFile(
      fileName: fileName,
      totalBytes: size,
      simulateError: simulateError,
    )) {
      print(progress);
      if (progress.isComplete) print('✅ Download complete!\n');
    }
  } on DownloadException catch (e) {
    print('❌ Download failed: $e');
  } finally {
    print('Cleanup for $fileName');
  }
}

// Parallel downloads
Future<void> downloadAll(List<(String, int)> files) async {
  await Future.wait([
    for (final (name, size) in files) runDownload(name, size),
  ]);
  print('All downloads finished.');
}

void main() async {
  await runDownload('report.pdf', 512000);
  await runDownload('corrupt.zip', 512000, simulateError: true);

  print('\n--- Parallel Downloads ---');
  await downloadAll([
    ('image1.png', 204800),
    ('video.mp4', 1048576),
    ('data.csv', 102400),
  ]);
}
```

---

# 📅 Day 7 — Isolates, Functional Programming & Core Libraries

---

## 7.1 Isolates

### Concept

Dart has **no shared memory** between isolates. Each isolate has its own heap. Communication happens via **message passing** using `SendPort` / `ReceivePort`. This avoids data races entirely.

Use isolates for:
- Heavy JSON parsing (>5MB payloads)
- Image processing / compression
- Complex computation (sorting, encrypting large datasets)

In Flutter, prefer `compute()` — it wraps `Isolate.spawn` with a clean API.

### Code Example

```dart
import 'dart:isolate';
import 'dart:math';

// The function must be top-level or static (not a closure)
// Message contains both data and the reply port
void heavyComputationIsolate(List<dynamic> message) {
  final SendPort replyPort = message[0] as SendPort;
  final List<int> data    = message[1] as List<int>;

  // Simulate CPU-intensive work: bubble sort
  final sorted = [...data];
  for (int i = 0; i < sorted.length; i++) {
    for (int j = 0; j < sorted.length - i - 1; j++) {
      if (sorted[j] > sorted[j + 1]) {
        final temp = sorted[j];
        sorted[j] = sorted[j + 1];
        sorted[j + 1] = temp;
      }
    }
  }

  replyPort.send(sorted);
}

Future<List<int>> sortInIsolate(List<int> data) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
    heavyComputationIsolate,
    [receivePort.sendPort, data],
  );

  final result = await receivePort.first as List<int>;
  receivePort.close();
  return result;
}

void main() async {
  final rng = Random();
  final bigList = List.generate(1000, (_) => rng.nextInt(10000));

  print('Sorting ${bigList.length} items in isolate...');
  final sorted = await sortInIsolate(bigList);
  print('First 10: ${sorted.take(10).toList()}');
  print('Last  10: ${sorted.skip(990).toList()}');
}
```

### Bidirectional Communication

```dart
// For back-and-forth communication, pass SendPort in both directions
void workerIsolate(SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort); // send back our port

  workerReceivePort.listen((message) {
    if (message == 'ping') mainSendPort.send('pong');
    if (message == 'quit') workerReceivePort.close();
  });
}
```

### Reference
[dart.dev — Isolates](https://dart.dev/language/isolates)

---

## 7.2 Functional Programming Patterns

### Concept

**Pure functions** have no side effects and return the same output for the same input. Combined with **immutability**, they make code easier to test and reason about.

Key HOFs: `map`, `where` (filter), `reduce`, `fold`, `expand` (flatMap).

**Closures** capture variables from their enclosing scope — enabling factories and partial application.

### Code Example

```dart
// Pure functions — same input, same output, no side effects
double discountedPrice(double price, double discountRate) =>
    price * (1 - discountRate);

// Higher-order functions
List<double> applyToAll(List<double> prices, double Function(double) transform) =>
    prices.map(transform).toList();

// Closure — captures outer variable
double Function(double) createDiscounter(double rate) =>
    (price) => price * (1 - rate); // closes over 'rate'

// Function composition
typedef Transform<T> = T Function(T input);

Transform<T> compose<T>(Transform<T> f, Transform<T> g) =>
    (input) => f(g(input));

// Immutable data processing pipeline
record OrderStats(double total, double average, double max, int count) {}

OrderStats analyzeOrders(List<double> orders) {
  // Pipeline: filter → transform → aggregate (no mutation)
  final validOrders = orders.where((o) => o > 0).toList();
  final total   = validOrders.fold(0.0, (sum, o) => sum + o);
  final average = validOrders.isEmpty ? 0.0 : total / validOrders.length;
  final maximum = validOrders.isEmpty ? 0.0 : validOrders.reduce((a, b) => a > b ? a : b);

  return (total: total, average: average, max: maximum, count: validOrders.length);
}

void main() {
  final prices = [29.99, 59.99, 99.99, 149.99, 199.99];

  // Closures as factories
  final tenOff     = createDiscounter(0.10);
  final twentyOff  = createDiscounter(0.20);
  final flashSale  = compose(tenOff, twentyOff); // 10% off after 20% off

  print(applyToAll(prices, tenOff));
  print(applyToAll(prices.take(2).toList(), flashSale));

  // expand (flatMap) — flatten nested structures
  final categories = [
    ['apple', 'banana'],
    ['carrot', 'daikon'],
    ['elderberry'],
  ];
  final allItems = categories.expand((list) => list).toList();
  print(allItems); // [apple, banana, carrot, daikon, elderberry]

  final stats = analyzeOrders([120.0, 0, -5, 80.0, 200.0, 50.0]);
  print('Total: ${stats.total}, Avg: ${stats.average.toStringAsFixed(2)}, Count: ${stats.count}');
}
```

---

## 7.3 Core Libraries — `dart:core`

### Key Types

```dart
import 'dart:core'; // always auto-imported

void demonstrateCore() {
  // DateTime
  final now   = DateTime.now();
  final epoch = DateTime(2024, 1, 1);
  final diff  = now.difference(epoch);
  print('Days since 2024-01-01: ${diff.inDays}');

  final formatted = '${now.year}-${now.month.toString().padLeft(2,'0')}-'
                    '${now.day.toString().padLeft(2,'0')}';
  print(formatted);

  // Duration arithmetic
  final deadline = now.add(Duration(days: 7, hours: 3));
  print('Deadline: $deadline');

  // RegExp
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final emails = ['test@example.com', 'not-an-email', 'user@domain.org'];
  for (final e in emails) {
    print('$e: ${emailRegex.hasMatch(e)}');
  }

  // StringBuffer — efficient string building
  final buffer = StringBuffer();
  for (int i = 1; i <= 5; i++) {
    buffer.write('Item $i');
    if (i < 5) buffer.write(', ');
  }
  print(buffer.toString()); // Item 1, Item 2, Item 3, Item 4, Item 5
}
```

---

## 7.4 Core Libraries — `dart:math`, `dart:convert`, `dart:io`

```dart
import 'dart:math';
import 'dart:convert';
import 'dart:io';

void demonstrateMath() {
  final rng = Random();
  print(rng.nextInt(100));          // 0–99
  print(rng.nextDouble());          // 0.0–1.0
  print(sqrt(144));                 // 12.0
  print(pow(2, 10));                // 1024
  print(max(42, 99));               // 99
  print(min(42, 99));               // 42
  print(log(e));                    // 1.0
}

void demonstrateConvert() {
  // JSON
  final user = {'name': 'Alice', 'age': 30, 'tags': ['dart', 'flutter']};
  final jsonStr = jsonEncode(user);
  print(jsonStr); // {"name":"Alice","age":30,"tags":["dart","flutter"]}

  final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
  print(decoded['name']); // Alice

  // Base64
  final message = 'Hello, Dart!';
  final encoded = base64Encode(utf8.encode(message));
  final decoded2 = utf8.decode(base64Decode(encoded));
  print(encoded);  // SGVsbG8sIERhcnQh
  print(decoded2); // Hello, Dart!
}

Future<void> demonstrateIO() async {
  // Write a file
  final file = File('output.txt');
  await file.writeAsString('Hello from dart:io!\nLine 2\nLine 3\n');

  // Read all lines
  final lines = await file.readAsLines();
  for (final line in lines) {
    print(line);
  }

  // Append to file
  final sink = file.openWrite(mode: FileMode.append);
  sink.writeln('Appended line');
  await sink.flush();
  await sink.close();

  // Check existence and delete
  if (await file.exists()) await file.delete();
}

void main() async {
  demonstrateMath();
  demonstrateConvert();
  await demonstrateIO();
}
```

### Reference
- [dart:convert](https://api.dart.dev/dart-convert/dart-convert-library.html)
- [dart:math](https://api.dart.dev/dart-math/dart-math-library.html)
- [dart:io](https://api.dart.dev/dart-io/dart-io-library.html)

---

## 7.5 Day 7 Practice — JSON Parsing

```dart
import 'dart:convert';

// Domain model
class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final bool inStock;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.inStock,
    required this.tags,
  });

  // fromJson factory — safe parsing with null coalescing
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:       json['id'] as int,
      name:     json['name'] as String,
      price:    (json['price'] as num).toDouble(),
      category: json['category'] as String,
      inStock:  json['in_stock'] as bool,
      tags:     (json['tags'] as List<dynamic>).cast<String>(),
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
  String toString() => 'Product($name, \$$price, ${inStock ? "in stock" : "out of stock"})';
}

// Repository with functional operations
class ProductRepository {
  final List<Product> _products;
  const ProductRepository(this._products);

  factory ProductRepository.fromJsonString(String json) {
    final data = jsonDecode(json) as List<dynamic>;
    final products = data
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    return ProductRepository(products);
  }

  List<Product> get inStock    => _products.where((p) => p.inStock).toList();
  List<Product> get outOfStock => _products.where((p) => !p.inStock).toList();

  List<Product> byCategory(String category) =>
      _products.where((p) => p.category == category).toList();

  Map<String, List<Product>> get groupedByCategory {
    final result = <String, List<Product>>{};
    for (final p in _products) {
      result.putIfAbsent(p.category, () => []).add(p);
    }
    return result;
  }

  double get averagePrice =>
      _products.fold(0.0, (sum, p) => sum + p.price) / _products.length;

  List<Product> search(String query) => _products
      .where((p) =>
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.tags.any((t) => t.contains(query.toLowerCase())))
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
  for (final p in repo.inStock) print('  $p');

  print('\n=== Electronics ===');
  for (final p in repo.byCategory('Electronics')) print('  $p');

  print('\n=== Search: "wireless" ===');
  for (final p in repo.search('wireless')) print('  $p');

  print('\n=== By Category ===');
  repo.groupedByCategory.forEach((cat, products) {
    print('  $cat: ${products.map((p) => p.name).join(', ')}');
  });

  print('\nAverage price: \$${repo.averagePrice.toStringAsFixed(2)}');
  print('Out of stock: ${repo.outOfStock.map((p) => p.name).join(', ')}');

  // Serialize back to JSON
  final backToJson = jsonEncode(repo.inStock.map((p) => p.toJson()).toList());
  print('\nRe-serialized (first 80 chars): ${backToJson.substring(0, 80)}...');
}
```

---

# 📅 Day 8 — Dart 3 Features + Null Safety Mastery + Code Quality

---

## 8.1 Dart 3 — Records

### Concept

**Records** are anonymous, immutable, **structural** value types. They're lightweight tuples — no class definition needed. They use value equality by default.

```dart
// Positional record
(int, String) pair = (42, 'hello');
var (number, text) = pair; // destructuring

// Named record
({int x, int y}) point = (x: 10, y: 20);
print(point.x); // 10

// Mixed
(int, {String name, double score}) result = (1, name: 'Alice', score: 98.5);
```

### Code Example

```dart
// Records as lightweight return types — no need for a full class
(double min, double max, double average) analyzeList(List<double> data) {
  if (data.isEmpty) return (0, 0, 0);
  final sorted = [...data]..sort();
  final avg = data.fold(0.0, (s, v) => s + v) / data.length;
  return (sorted.first, sorted.last, avg);
}

// Named fields for clarity
({String firstName, String lastName, int age}) parseUserCsv(String csv) {
  final parts = csv.split(',');
  return (
    firstName: parts[0].trim(),
    lastName:  parts[1].trim(),
    age:       int.parse(parts[2].trim()),
  );
}

// Records in collections
List<(String, double)> topProducts(Map<String, double> sales) {
  return sales.entries
      .map((e) => (e.key, e.value))
      .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
}

void main() {
  // Destructuring
  final (min, max, avg) = analyzeList([3.5, 1.2, 9.8, 4.4, 7.1]);
  print('Min: $min, Max: $max, Avg: ${avg.toStringAsFixed(2)}');

  // Named destructuring
  final (:firstName, :lastName, :age) = parseUserCsv('Alice, Smith, 30');
  print('$firstName $lastName, age $age');

  // Records have structural equality
  final r1 = (1, 'a');
  final r2 = (1, 'a');
  print(r1 == r2); // true (value equality)

  final sales = {'Laptop': 45200.0, 'Phone': 82100.0, 'Tablet': 31000.0};
  for (final (name, amount) in topProducts(sales)) {
    print('$name: \$${amount.toStringAsFixed(0)}');
  }
}
```

### Reference
[dart.dev — Records](https://dart.dev/language/records)

---

## 8.2 Dart 3 — Pattern Matching Deep Dive

### Concept

Patterns in Dart 3 can appear in:
- `switch` expressions and statements
- `if-case` statements
- Variable declarations (destructuring)
- `for-in` loops

### Pattern Types Reference

```dart
void patternExamples() {
  // 1. Object pattern
  final point = (x: 3, y: 4);
  final (x: px, y: py) = point;
  print('$px, $py'); // 3, 4

  // 2. List pattern
  final [first, second, ...rest] = [1, 2, 3, 4, 5];
  print('$first $second $rest'); // 1 2 [3, 4, 5]

  // 3. Map pattern
  final json = {'name': 'Alice', 'age': 30};
  final {'name': String name, 'age': int age} = json;
  print('$name, $age'); // Alice, 30

  // 4. switch with guard
  final scores = [95, 42, 78, 100, 55];
  for (final score in scores) {
    final grade = switch (score) {
      int s when s >= 90 => 'A',
      int s when s >= 80 => 'B',
      int s when s >= 70 => 'C',
      int s when s >= 60 => 'D',
      _                  => 'F',
    };
    print('$score → $grade');
  }

  // 5. if-case — single pattern check
  dynamic value = (42, 'hello');
  if (value case (int n, String s) when n > 10) {
    print('Got int $n and string $s'); // Got int 42 and string hello
  }
}
```

### Exhaustive Matching with Sealed Classes

```dart
sealed class Expr {}
class Num   extends Expr { final double value; Num(this.value); }
class Add   extends Expr { final Expr left, right; Add(this.left, this.right); }
class Mul   extends Expr { final Expr left, right; Mul(this.left, this.right); }
class Neg   extends Expr { final Expr operand; Neg(this.operand); }

double evaluate(Expr expr) => switch (expr) {
  Num(:final value)                    => value,
  Add(:final left, :final right)       => evaluate(left) + evaluate(right),
  Mul(:final left, :final right)       => evaluate(left) * evaluate(right),
  Neg(:final operand)                  => -evaluate(operand),
};

void main() {
  // (3 + 4) * -(2)
  final expression = Mul(
    Add(Num(3), Num(4)),
    Neg(Num(2)),
  );
  print(evaluate(expression)); // -14.0
  patternExamples();
}
```

### Reference
[dart.dev — Pattern types](https://dart.dev/language/pattern-types)

---

## 8.3 Null Safety Mastery

### Concept

Dart's **sound null safety** guarantees at **compile time** that non-nullable types can never be `null`. This eliminates entire classes of `NullPointerException` bugs.

| Syntax | Meaning |
|---|---|
| `String` | Never null, guaranteed |
| `String?` | May be null |
| `!` | Assert non-null (throws if null) |
| `?.` | Null-safe access |
| `??` | Null coalescing: use default if null |
| `??=` | Assign only if currently null |
| `late` | Non-nullable, initialized later |
| `late final` | Non-nullable, set exactly once |

### Code Example

```dart
// API boundary — nullable coming in, non-nullable going out
class UserPreferences {
  late final String userId;        // set in init(), not constructor
  String displayName;
  String? bio;                     // genuinely optional
  int notificationCount = 0;

  UserPreferences({required this.displayName});

  void init(String id) {
    userId = id;                   // set exactly once
  }

  // Null safety at API boundaries
  String get safeBio => bio ?? 'No bio provided';
  String get shortBio => bio?.substring(0, bio!.length.clamp(0, 50)) ?? '';

  // ??= — lazy default
  String? _cachedSummary;
  String get summary {
    _cachedSummary ??= '$displayName: $safeBio';
    return _cachedSummary!;
  }
}

// Working with nullable in collections
List<String> safeNames(List<String?> raw) =>
    raw.whereType<String>().toList(); // filters out nulls, widens type

// Late — for dependency injection and lazy init
class ApiClient {
  late final String baseUrl;
  late final Map<String, String> headers;

  void configure(String url, {String? authToken}) {
    baseUrl = url;
    headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  String buildUrl(String path) => '$baseUrl$path';
}

// Null safety migration patterns
String? maybeGetUser(int id) => id > 0 ? 'user_$id' : null;

void processUser(int id) {
  // Pattern 1: early return
  final user = maybeGetUser(id);
  if (user == null) {
    print('User $id not found');
    return;
  }
  // user is promoted to String here
  print('Processing: ${user.toUpperCase()}');

  // Pattern 2: if-case with pattern
  if (maybeGetUser(id * 2) case final String u) {
    print('Related user: $u');
  }
}

void main() {
  final prefs = UserPreferences(displayName: 'Alice');
  prefs.init('user_123');
  prefs.bio = 'Dart enthusiast and Flutter developer.';

  print(prefs.summary);
  print(prefs.safeBio);

  print(safeNames(['Alice', null, 'Bob', null, 'Charlie'])); // [Alice, Bob, Charlie]

  processUser(5);
  processUser(-1);

  final client = ApiClient();
  client.configure('https://api.example.com', authToken: 'abc123');
  print(client.buildUrl('/users'));
}
```

### Reference
[dart.dev — Null safety](https://dart.dev/null-safety)

---

## 8.4 Code Quality — `dart analyze`, Lints, `dart format`

### `dart analyze`

Static analysis catches errors and style violations before runtime.

```bash
# Run analysis
dart analyze

# Fix auto-fixable issues
dart fix --apply
```

### `dart format`

Opinionated formatter — no configuration needed. Enforces 80-char lines, consistent spacing, trailing commas.

```bash
dart format .              # format all files
dart format lib/main.dart  # format single file
dart format --output=show lib/main.dart  # preview without writing
```

### Recommended `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml  # or lints/recommended.yaml for pure Dart

analyzer:
  exclude:
    - '**/*.g.dart'   # generated files
    - '**/*.freezed.dart'
  errors:
    missing_required_param: error
    missing_return: error

linter:
  rules:
    # Dart 3 style
    - prefer_final_locals
    - prefer_final_in_for_each
    - unnecessary_nullable_for_final_variable_declarations
    - use_super_parameters

    # Safety
    - avoid_dynamic_calls
    - avoid_print             # use a logger in production
    - cancel_subscriptions
    - close_sinks

    # Collections
    - prefer_collection_literals
    - prefer_spread_collections

    # Async
    - unawaited_futures
    - avoid_void_async
```

### Common Warnings & Fixes

```dart
// ⚠️  avoid_print → use a logger
// BAD
print('error occurred');
// GOOD
import 'package:logging/logging.dart';
final _log = Logger('MyClass');
_log.warning('error occurred');

// ⚠️  unawaited_futures → missing await
// BAD
void badMethod() {
  someAsyncOperation(); // fire and forget = unhandled error
}
// GOOD
Future<void> goodMethod() async {
  await someAsyncOperation();
}

// ⚠️  prefer_final_locals → mutability should be intentional
// BAD
var name = 'Alice';      // name never reassigned
// GOOD
final name = 'Alice';

// ⚠️  use_super_parameters (Dart 2.17+)
// BAD
class Dog extends Animal {
  Dog(String name) : super(name);
}
// GOOD
class Dog extends Animal {
  Dog(super.name);
}
```

### Reference
[dart.dev — dart analyze](https://dart.dev/tools/dart-analyze)

---

# 🎯 Phase 1 Mini-Project — Dart CLI Quiz App

A complete, runnable CLI quiz app demonstrating everything from Days 4–8.

## Project Structure

```
dart_quiz/
├── analysis_options.yaml
├── pubspec.yaml
└── bin/
    └── main.dart
```

## `pubspec.yaml`

```yaml
name: dart_quiz
description: CLI Quiz App — Dart 3 Mini-Project
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
```

## `bin/main.dart`

```dart
import 'dart:convert';
import 'dart:io';

// ============================================================
// DOMAIN MODELS — Sealed class hierarchy for question types
// ============================================================

sealed class Question {
  final String id;
  final String text;
  final int points;

  const Question({
    required this.id,
    required this.text,
    required this.points,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'multiple_choice' => MultipleChoice.fromJson(json),
      'true_false'      => TrueFalse.fromJson(json),
      _ => throw ParseException('Unknown question type: $type'),
    };
  }

  bool checkAnswer(String answer);
  String get formattedQuestion;
}

class MultipleChoice extends Question {
  final List<String> options;
  final String correctOption; // 'A', 'B', 'C', or 'D'

  const MultipleChoice({
    required super.id,
    required super.text,
    required super.points,
    required this.options,
    required this.correctOption,
  });

  factory MultipleChoice.fromJson(Map<String, dynamic> json) {
    return MultipleChoice(
      id:            json['id'] as String,
      text:          json['text'] as String,
      points:        json['points'] as int,
      options:       (json['options'] as List<dynamic>).cast<String>(),
      correctOption: json['correct'] as String,
    );
  }

  @override
  bool checkAnswer(String answer) =>
      answer.trim().toUpperCase() == correctOption.toUpperCase();

  @override
  String get formattedQuestion {
    final labels = ['A', 'B', 'C', 'D'];
    final buffer = StringBuffer('$text\n');
    for (int i = 0; i < options.length; i++) {
      buffer.writeln('  ${labels[i]}) ${options[i]}');
    }
    return buffer.toString();
  }
}

class TrueFalse extends Question {
  final bool correctAnswer;

  const TrueFalse({
    required super.id,
    required super.text,
    required super.points,
    required this.correctAnswer,
  });

  factory TrueFalse.fromJson(Map<String, dynamic> json) {
    return TrueFalse(
      id:            json['id'] as String,
      text:          json['text'] as String,
      points:        json['points'] as int,
      correctAnswer: json['correct'] as bool,
    );
  }

  @override
  bool checkAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    return switch (normalized) {
      'true'  || 't' || 'yes' => correctAnswer == true,
      'false' || 'f' || 'no'  => correctAnswer == false,
      _ => false,
    };
  }

  @override
  String get formattedQuestion => '$text\n  (Enter: true/false)';
}

// ============================================================
// EXCEPTIONS
// ============================================================

class ParseException implements Exception {
  final String message;
  const ParseException(this.message);
  @override
  String toString() => 'ParseException: $message';
}

class InvalidInputException implements Exception {
  final String input;
  final String reason;
  const InvalidInputException(this.input, this.reason);
  @override
  String toString() => 'InvalidInput("$input"): $reason';
}

// ============================================================
// IMMUTABLE SCORE STATE — no mutation, return new instances
// ============================================================

class QuizState {
  final int currentIndex;
  final int score;
  final int totalPoints;
  final List<(String questionId, bool correct)> answers;

  const QuizState({
    this.currentIndex = 0,
    this.score        = 0,
    this.totalPoints  = 0,
    this.answers      = const [],
  });

  QuizState recordAnswer({
    required String questionId,
    required bool correct,
    required int points,
  }) {
    return QuizState(
      currentIndex: currentIndex + 1,
      score:        correct ? score + points : score,
      totalPoints:  totalPoints + points,
      answers:      [...answers, (questionId, correct)],
    );
  }

  double get percentage =>
      totalPoints == 0 ? 0 : (score / totalPoints) * 100;

  String get grade => switch (percentage) {
    >= 90 => 'A',
    >= 80 => 'B',
    >= 70 => 'C',
    >= 60 => 'D',
    _     => 'F',
  };
}

// ============================================================
// QUIZ ENGINE
// ============================================================

class QuizEngine {
  final List<Question> questions;

  const QuizEngine(this.questions);

  factory QuizEngine.fromJsonString(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as List<dynamic>;
      final questions = data
          .cast<Map<String, dynamic>>()
          .map(Question.fromJson)
          .toList();
      if (questions.isEmpty) throw ParseException('No questions found in JSON');
      return QuizEngine(questions);
    } on FormatException catch (e) {
      throw ParseException('Invalid JSON format: ${e.message}');
    }
  }

  Future<QuizState> run() async {
    var state = const QuizState();

    _printHeader();

    for (final question in questions) {
      state = await _askQuestion(question, state);
    }

    return state;
  }

  Future<QuizState> _askQuestion(
      Question question, QuizState state) async {
    // Simulate question load delay
    await Future.delayed(Duration(milliseconds: 300));

    final questionNum = state.currentIndex + 1;
    print('\n--- Question $questionNum/${questions.length} [${question.points} pts] ---');
    print(question.formattedQuestion);

    String? answer;
    int attempts = 0;

    while (answer == null) {
      try {
        stdout.write('Your answer: ');
        final input = stdin.readLineSync()?.trim();
        answer = _validateInput(question, input);
      } on InvalidInputException catch (e) {
        attempts++;
        if (attempts >= 3) {
          print('⚠️  Too many invalid attempts. Marking as incorrect.');
          answer = '__invalid__';
        } else {
          print('  ❌ ${e.reason} (${3 - attempts} attempts left)');
        }
      }
    }

    final correct = question.checkAnswer(answer);
    print(correct ? '  ✅ Correct!' : '  ❌ Incorrect.');

    return state.recordAnswer(
      questionId: question.id,
      correct: correct,
      points: question.points,
    );
  }

  String _validateInput(Question question, String? input) {
    if (input == null || input.isEmpty) {
      throw InvalidInputException('', 'Answer cannot be empty');
    }

    return switch (question) {
      MultipleChoice() => _validateMultipleChoice(input),
      TrueFalse()      => _validateTrueFalse(input),
    };
  }

  String _validateMultipleChoice(String input) {
    final upper = input.toUpperCase();
    if (!RegExp(r'^[A-D]$').hasMatch(upper)) {
      throw InvalidInputException(input, 'Enter A, B, C, or D');
    }
    return upper;
  }

  String _validateTrueFalse(String input) {
    final lower = input.toLowerCase();
    if (!{'true', 'false', 't', 'f', 'yes', 'no'}.contains(lower)) {
      throw InvalidInputException(input, 'Enter true or false');
    }
    return lower;
  }

  void _printHeader() {
    print('');
    print('╔══════════════════════════════════╗');
    print('║       🎯  DART QUIZ APP  🎯      ║');
    print('╠══════════════════════════════════╣');
    print('║  ${questions.length} questions | ${questions.fold(0, (s, q) => s + q.points)} total points   ║');
    print('╚══════════════════════════════════╝');
  }
}

// ============================================================
// RESULT PRINTER
// ============================================================

void printResults(QuizState state, List<Question> questions) {
  print('\n╔══════════════════════════════════╗');
  print('║           QUIZ COMPLETE!          ║');
  print('╠══════════════════════════════════╣');
  print('║  Score:  ${state.score}/${state.totalPoints} pts'.padRight(35) + '║');
  print('║  Grade:  ${state.grade}'.padRight(35) + '║');
  print('║  Pct:    ${state.percentage.toStringAsFixed(1)}%'.padRight(35) + '║');
  print('╚══════════════════════════════════╝');

  print('\nQuestion Breakdown:');
  for (final (id, correct) in state.answers) {
    final q = questions.firstWhere((q) => q.id == id);
    final icon = correct ? '✅' : '❌';
    final pts  = correct ? '+${q.points}' : '+0';
    print('  $icon  [$pts pts]  ${q.text.substring(0, q.text.length.clamp(0, 50))}');
  }

  final message = switch (state.grade) {
    'A' => '🏆 Outstanding! You clearly know your Dart!',
    'B' => '🎉 Great work! A bit more practice and you\'ll ace it.',
    'C' => '👍 Decent effort. Review the missed topics.',
    'D' => '📚 You passed, but there\'s room to grow.',
    _   => '💪 Don\'t give up! Review the material and try again.',
  };
  print('\n$message');
}

// ============================================================
// QUIZ DATA
// ============================================================

const quizJson = '''
[
  {
    "type": "multiple_choice",
    "id": "q1",
    "text": "Which keyword makes a Dart variable non-nullable and set exactly once?",
    "points": 10,
    "options": [
      "final",
      "const",
      "late final",
      "static final"
    ],
    "correct": "C"
  },
  {
    "type": "true_false",
    "id": "q2",
    "text": "In Dart 3, a sealed class can be extended from a different file.",
    "points": 10,
    "correct": false
  },
  {
    "type": "multiple_choice",
    "id": "q3",
    "text": "What does Future.wait() do?",
    "points": 15,
    "options": [
      "Executes futures sequentially one after another",
      "Waits for all futures in parallel and collects results",
      "Cancels all futures if one fails",
      "Creates a new Future with a delay"
    ],
    "correct": "B"
  },
  {
    "type": "true_false",
    "id": "q4",
    "text": "Dart isolates share memory with each other by default.",
    "points": 10,
    "correct": false
  },
  {
    "type": "multiple_choice",
    "id": "q5",
    "text": "Which Dart 3 feature provides structural, anonymous value types with value equality?",
    "points": 15,
    "options": [
      "Sealed classes",
      "Enhanced enums",
      "Records",
      "Extension types"
    ],
    "correct": "C"
  }
]
''';

// ============================================================
// ENTRY POINT
// ============================================================

void main() async {
  try {
    final engine = QuizEngine.fromJsonString(quizJson);
    final finalState = await engine.run();
    printResults(finalState, engine.questions);
  } on ParseException catch (e) {
    print('❌ Failed to load quiz: $e');
    exitCode = 1;
  } catch (e, stack) {
    print('❌ Unexpected error: $e');
    print(stack);
    exitCode = 1;
  }
}
```

## Running the App

```bash
dart run bin/main.dart
```

---

# Self-Review Checklist Before Phase 2

Use this to gauge readiness. For anything marked uncertain, revisit the relevant day.

## Null Safety
- [ ] Can you explain why `String` and `String?` are different **types** in Dart's type system?
- [ ] Do you know when to use `late` vs `late final` vs a nullable `?`?
- [ ] Can you spot a potential `!` operator misuse and refactor it safely?

## Async
- [ ] Can you write an `async/await` function without looking at the docs?
- [ ] Do you understand why `Future.wait()` is faster than sequential `await`?
- [ ] Can you create a `Stream` with `async*` and `yield`?
- [ ] Do you know the difference between single-subscription and broadcast streams?

## OOP & Modelling
- [ ] Can you model a domain with a sealed class + exhaustive switch?
- [ ] Do you understand when to use `mixin` instead of inheritance?
- [ ] Can you implement a generic class with a bounded type (`<T extends Comparable>`)?

## Collections & Functional Style
- [ ] Are you comfortable chaining `where`, `map`, `fold` without intermediate variables?
- [ ] Do you know the difference between `reduce` and `fold`?
- [ ] Can you use `collection if` and `collection for` inside list literals?

## Dart 3
- [ ] Can you return a record from a function and destructure it at the call site?
- [ ] Can you write a pattern-matching `switch` that the compiler verifies as exhaustive?
- [ ] Can you use guard clauses (`when`) in a switch expression?

---

*End of Days 4–8 Course Material*
