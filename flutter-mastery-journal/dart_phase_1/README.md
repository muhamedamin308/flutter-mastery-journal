We’ll go through Days 4 to 8, one topic at a time. Each topic includes a clear concept, practical code examples, links for deeper reading, and a quick check-in quiz. Let's dive in.

---

# 📅 Day 4 — Control Flow, Functions & Collections

## 🔁 Topic: Loops (`for`, `for-in`, `while`, `do-while`)

### Concept
Loops repeat a block of code. Dart provides:
- **`for` loop**: classic counting loop.
- **`for-in` loop**: iterates over collections (list, set, map keys, etc.).
- **`while` loop**: checks condition before each iteration.
- **`do-while` loop**: executes at least once, then checks condition.

### Code Examples
```dart
void main() {
  // for loop – typical counter
  for (int i = 0; i < 5; i++) {
    print('Iteration $i');
  }

  // for-in with a list
  var fruits = ['apple', 'banana', 'cherry'];
  for (var fruit in fruits) {
    print('I love $fruit');
  }

  // while – read until condition false
  int attempts = 0;
  while (attempts < 3) {
    print('Attempt ${attempts + 1}');
    attempts++;
  }

  // do-while – guarantee at least one run
  int input;
  do {
    input = int.tryParse('invalid') ?? -1; // simulate user input
    print('Received: $input');
  } while (input < 0);
}
```

### External Reference
- [Dart Language Tour: Loops](https://dart.dev/language/loops)
- [W3Schools: Dart Loops](https://www.w3schools.com/dart/dart_loops.php)

### ✅ Check-in Quiz
**Q1:** What will the following code print?
```dart
var items = [1, 2, 3];
for (var item in items) {
  if (item == 2) break;
  print(item);
}
```
A) `1 2`  
B) `1`  
C) `2`  
D) `1 2 3`  

**Q2 (find the bug):** This loop is meant to count down from 5 to 1. Why doesn't it work?
```dart
int count = 5;
while (count > 0) {
  print(count);
}
```

<details><summary>Answers</summary>
Q1: B) `1` (break exits the loop when item is 2, so only 1 prints)<br>
Q2: `count` is never decremented → infinite loop. Add `count--;` inside the loop.
</details>

---

## 🛑 Topic: `break`, `continue`, and Labelled Loops

### Concept
- **`break`**: exits the nearest enclosing loop or switch.
- **`continue`**: skips the current iteration and moves to the next.
- **Labelled loops**: give a name to a loop so you can `break` or `continue` from an outer loop.

### Code Examples
```dart
void main() {
  // break example
  for (int i = 1; i <= 10; i++) {
    if (i > 5) break;
    print(i);
  } // prints 1..5

  // continue example
  for (int i = 1; i <= 5; i++) {
    if (i == 3) continue;
    print(i);
  } // prints 1,2,4,5

  // labelled loops – exit outer loop from inside inner
  outerLoop:
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (i == 1 && j == 1) break outerLoop;
      print('$i, $j');
    }
  }
  // prints: 0,0  0,1  0,2  1,0
}
```

### External Reference
- [Dart Language Tour: Break and Continue](https://dart.dev/language/loops#break-and-continue)

### ✅ Check-in Quiz
**Q:** What is the output?
```dart
outer:
for (int i = 0; i < 2; i++) {
  for (int j = 0; j < 2; j++) {
    if (i == 1 && j == 0) continue outer;
    print('$i,$j');
  }
}
```
A) `0,0 0,1 1,1`  
B) `0,0 0,1 1,0 1,1`  
C) `0,0 0,1`  
D) `0,0 0,1 1,0`

<details><summary>Answer</summary>
A) `0,0 0,1 1,1`. When `i==1 && j==0`, `continue outer` jumps to the next iteration of the outer loop (i=2), so the inner loop never prints `1,0`.
</details>

---

## 🔍 Topic: Named Parameters, Positional Parameters, and Arrow Functions

### Concept
- **Named parameters**: wrapped in `{}`, can be required or optional. Call with `name: value`.
- **Positional parameters**: wrapped in `[]`, optional, can have defaults.
- **Arrow functions (`=>`)**: shorthand for single-expression functions.

### Code Examples
```dart
// Named parameters with required
void greet({required String name, String? title}) {
  print('Hello, ${title != null ? '$title ' : ''}$name');
}

// Positional optional parameters
void log(String message, [String? prefix, int? priority = 0]) {
  print('${prefix ?? ''} $message (priority: $priority)');
}

// Arrow function
int add(int a, int b) => a + b;

void main() {
  greet(name: 'Alice', title: 'Dr.');       // Hello, Dr. Alice
  greet(name: 'Bob');                       // Hello, Bob
  log('Error', 'ERROR:', 5);                // ERROR:  Error (priority: 5)
  log('Info');                              //  Info (priority: 0)
  print(add(2, 3));                         // 5
}
```

### External Reference
- [Dart Language Tour: Functions](https://dart.dev/language/functions#parameters)

### ✅ Check-in Quiz
**Q:** Which call to `createUser` is valid?
```dart
void createUser(String name, {int age = 0, required String email}) {
  // ...
}
```
A) `createUser('John', 25, email: 'j@e.com')`  
B) `createUser('John', email: 'j@e.com')`  
C) `createUser(email: 'j@e.com', 'John')`  
D) `createUser('John', age: 25)`

<details><summary>Answer</summary>
B is valid. Named parameters can be omitted if they have defaults, but `email` is required and must be named. Positional parameters cannot be mixed after named parameters.
</details>

---

## 🧩 Topic: First‑class Functions, Anonymous Functions, and `typedef`

### Concept
- **First‑class functions**: functions can be assigned to variables, passed as arguments, and returned.
- **Anonymous functions**: also called lambdas; defined without a name.
- **`typedef`**: gives a name to a function type signature.

### Code Examples
```dart
typedef IntOperation = int Function(int a, int b);

// Higher-order function: takes a function as argument
int applyOperation(int x, int y, IntOperation op) {
  return op(x, y);
}

void main() {
  // Assign function to variable
  var multiply = (int a, int b) => a * b;
  print(multiply(3, 4)); // 12

  // Anonymous function passed directly
  int sum = applyOperation(10, 5, (a, b) => a + b);
  print(sum); // 15

  // Using typedef
  IntOperation subtract = (a, b) => a - b;
  print(applyOperation(10, 5, subtract)); // 5
}
```

### External Reference
- [Dart Language Tour: Functions – First‑class](https://dart.dev/language/functions#functions-as-first-class-objects)
- [Dart: Typedefs](https://dart.dev/language/typedefs)

### ✅ Check-in Quiz
**Q:** What does this code print?
```dart
List<int> numbers = [1, 2, 3];
var squared = numbers.map((n) => n * n).toList();
print(squared);
```
A) `[1, 2, 3]`  
B) `[1, 4, 9]`  
C) `[1, 4, 9, 16]`  
D) Error: cannot assign function to variable.

<details><summary>Answer</summary>
B) `[1, 4, 9]`. `map` applies the lambda to each element, producing a new iterable.
</details>

---

## 📚 Topic: Collections Deep Dive — List, Map, Set

### Concept
- **List**: ordered, indexable, allows duplicates.
- **Map**: key-value pairs, keys unique.
- **Set**: unordered, unique elements.
- Powerful methods: `where`, `map`, `reduce`, `fold`, `sort`, `contains`, `addAll`, `putIfAbsent`, `intersection`, etc.

### Code Examples
```dart
void main() {
  // --- List operations ---
  var numbers = [1, 2, 3, 4];
  numbers.addAll([5, 6]);
  print(numbers); // [1,2,3,4,5,6]

  var evens = numbers.where((n) => n.isEven).toList();
  print(evens); // [2,4,6]

  var sum = numbers.reduce((a, b) => a + b);
  print(sum); // 21

  // --- Map operations ---
  var ages = {'Alice': 30, 'Bob': 25};
  ages.putIfAbsent('Charlie', () => 35);
  ages.update('Bob', (value) => value + 1);
  print(ages); // {Alice:30, Bob:26, Charlie:35}

  // --- Set operations ---
  var setA = {1, 2, 3};
  var setB = {3, 4, 5};
  print(setA.intersection(setB)); // {3}
  print(setA.union(setB));        // {1,2,3,4,5}
  print(setA.difference(setB));   // {1,2}
}
```

### External Reference
- [Dart Language Tour: Collections](https://dart.dev/language/collections)
- [List class](https://api.dart.dev/stable/dart-core/List-class.html)
- [Set class](https://api.dart.dev/stable/dart-core/Set-class.html)
- [Map class](https://api.dart.dev/stable/dart-core/Map-class.html)

### ✅ Check-in Quiz
**Q:** What does `fold` do? Complete the code to compute the product of all numbers.
```dart
var numbers = [2, 3, 4];
var product = numbers.fold(1, (acc, n) => ___);
print(product); // 24
```
A) `acc + n`  
B) `acc * n`  
C) `acc - n`  
D) `n`

<details><summary>Answer</summary>
B) `acc * n`. `fold` starts with the initial value (1) and applies the operation to combine with each element.
</details>

---

## 🛒 Practice: Shopping Cart in Pure Dart

### Goal
Implement a shopping cart that can:
- Add items (name, price, quantity).
- Remove items.
- Compute total.
- Show cart contents.

Use collections and functions we’ve learned.

### Starter Code & Solution
```dart
class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem(this.name, this.price, this.quantity);
}

class ShoppingCart {
  final List<CartItem> _items = [];

  void addItem(String name, double price, [int quantity = 1]) {
    var existing = _items.firstWhere((item) => item.name == name, orElse: () => null);
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItem(name, price, quantity));
    }
  }

  void removeItem(String name) {
    _items.removeWhere((item) => item.name == name);
  }

  double get total => _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void showCart() {
    if (_items.isEmpty) {
      print('Cart is empty.');
      return;
    }
    print('--- Shopping Cart ---');
    for (var item in _items) {
      print('${item.name} x${item.quantity} = \$${item.price * item.quantity}');
    }
    print('Total: \$${total.toStringAsFixed(2)}');
  }
}

void main() {
  var cart = ShoppingCart();
  cart.addItem('Apple', 0.5, 3);
  cart.addItem('Banana', 0.3, 2);
  cart.addItem('Apple', 0.5); // adds one more apple
  cart.showCart();
  cart.removeItem('Banana');
  cart.showCart();
}
```

---

# 📅 Day 5 — OOP in Dart

## 🏗️ Topic: Constructors (Default, Named, Factory, Const)

### Concept
- **Default constructor**: same as class name, no arguments.
- **Named constructors**: multiple ways to create objects.
- **Factory constructor**: can return a cached instance or a subtype; doesn't always create a new object.
- **Const constructor**: allows compile‑time constants if all fields are final.

### Code Examples
```dart
class Point {
  final double x, y;

  // Default constructor (implicit)
  Point(this.x, this.y);

  // Named constructor
  Point.origin() : this(0, 0);

  // Factory constructor – returns a cached instance
  static final _cache = <double, Point>{};
  factory Point.cached(double x, double y) {
    return _cache.putIfAbsent(x + y, () => Point(x, y));
  }

  // Const constructor (requires all fields final)
  const Point.constVersion(this.x, this.y);
}

void main() {
  var p1 = Point(1, 2);
  var p2 = Point.origin();
  var p3 = Point.cached(3, 4);
  var p4 = const Point.constVersion(5, 6);
}
```

### External Reference
- [Dart Language Tour: Constructors](https://dart.dev/language/constructors)

### ✅ Check-in Quiz
**Q:** What’s the purpose of a factory constructor?
A) To create a new instance every time.  
B) To return an instance from a cache or a subtype.  
C) To initialize final fields.  
D) To make a constructor private.

<details><summary>Answer</summary>
B) A factory constructor can return an existing instance or a subtype; it doesn’t always create a new object.
</details>

---

## 🔁 Topic: Inheritance (`extends`, `super`, Overriding, Abstract Classes)

### Concept
- **`extends`** creates a subclass.
- **`super`** calls the parent constructor or method.
- **Method overriding**: subclass provides its own implementation.
- **Abstract classes** cannot be instantiated; can have abstract methods (no body).

### Code Examples
```dart
abstract class Animal {
  void makeSound(); // abstract method
  void breathe() => print('Breathing...');
}

class Dog extends Animal {
  @override
  void makeSound() => print('Woof!');

  void fetch() => print('Fetching stick');
}

void main() {
  var dog = Dog();
  dog.makeSound(); // Woof!
  dog.breathe();   // Breathing...
  dog.fetch();     // Fetching stick
}
```

### External Reference
- [Dart Language Tour: Extending a class](https://dart.dev/language/extend)

### ✅ Check-in Quiz
**Q:** What happens if a subclass does not override an abstract method?
A) Compile‑time error.  
B) Runtime error.  
C) The method is ignored.  
D) It calls the parent's version (if any).

<details><summary>Answer</summary>
A) Compile‑time error. Abstract methods must be implemented in concrete subclasses.
</details>

---

## 🧩 Topic: Interfaces (`implements`) and Mixins (`mixin`, `with`)

### Concept
- **`implements`**: a class can implement multiple interfaces; it must provide all methods and fields of those interfaces.
- **Mixins** (`mixin` + `with`): reuse code from multiple sources without inheritance. A mixin is like a class but cannot have constructors.

### Code Examples
```dart
mixin Flyable {
  void fly() => print('Flying!');
}

mixin Swimmable {
  void swim() => print('Swimming!');
}

class Duck implements Flyable, Swimmable {
  // implements forces us to provide implementations
  @override
  void fly() => print('Duck flies low');
  @override
  void swim() => print('Duck paddles');
}

class SuperDuck with Flyable, Swimmable {
  // with automatically includes the mixin implementations
}

void main() {
  var duck = Duck();
  duck.fly();  // Duck flies low
  duck.swim(); // Duck paddles

  var superDuck = SuperDuck();
  superDuck.fly();  // Flying!
  superDuck.swim(); // Swimming!
}
```

### External Reference
- [Dart Language Tour: Implements](https://dart.dev/language/interfaces)
- [Dart Language Tour: Mixins](https://dart.dev/language/mixins)

### ✅ Check-in Quiz
**Q:** What’s the difference between `extends` and `implements`?
A) `extends` inherits implementation; `implements` only inherits interface (must re‑implement).  
B) `extends` is for single inheritance; `implements` for multiple.  
C) Both are correct.  
D) None of the above.

<details><summary>Answer</summary>
C) Both are correct. `extends` inherits implementation (and can override), while `implements` forces you to provide all members.
</details>

---

## 🔒 Topic: `sealed` Classes (Dart 3) for Exhaustive Pattern Matching

### Concept
- **`sealed`** classes restrict subclassing to a known set. The compiler can exhaustively check `switch` statements when used with pattern matching.

### Code Examples
```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final String message;
  const Error(this.message);
}

String handleResult<T>(Result<T> result) {
  return switch (result) {
    Success(value: var data) => 'Data: $data',
    Error(message: var msg) => 'Error: $msg',
  }; // No default needed – exhaustive
}
```

### External Reference
- [Dart 3: Sealed Classes](https://dart.dev/language/class-modifiers#sealed)

### ✅ Check-in Quiz
**Q:** What does the compiler enforce with `sealed`?
A) You cannot create instances.  
B) All subclasses must be defined in the same library.  
C) Switch statements on the sealed type must cover all subclasses.  
D) Both B and C.

<details><summary>Answer</summary>
D) Both B and C. Subclasses must be in the same library, and switch statements are exhaustive.
</details>

---

## 🌟 Topic: Enhanced Enums, Extension Methods, Generics

### Concept
- **Enhanced enums**: can have fields, methods, constructors.
- **Extension methods**: add functionality to existing types without subclassing.
- **Generics**: create classes/methods that work with any type, with optional bounds.

### Code Examples
```dart
// Enhanced enum
enum Status {
  loading('Loading...'),
  success('Done!'),
  error('Failed');

  final String message;
  const Status(this.message);
}

// Extension method
extension NumberParsing on String {
  int parseInt() => int.parse(this);
}

// Generic class
class Box<T> {
  final T value;
  Box(this.value);
}

void main() {
  print(Status.loading.message); // Loading...
  print('42'.parseInt());        // 42
  var box = Box<int>(100);
  print(box.value);              // 100
}
```

### External Reference
- [Enums](https://dart.dev/language/enums)
- [Extension methods](https://dart.dev/language/extension-methods)
- [Generics](https://dart.dev/language/generics)

### ✅ Check-in Quiz
**Q:** What does the extension method below do?
```dart
extension on List<int> {
  int get sum => fold(0, (a, b) => a + b);
}
```
A) Adds a property `sum` to all lists of integers.  
B) Adds a method `sum()` that returns the total.  
C) Adds a getter `sum` that returns the total.  
D) Both A and C.

<details><summary>Answer</summary>
D) Both A and C – it adds a getter `sum` to `List<int>`.
</details>

---

## 🏦 Practice: Bank Account Hierarchy

### Goal
Model a `BankAccount` hierarchy with:
- `SavingsAccount` (interest rate)
- `CheckingAccount` (overdraft limit)
- Mixin `Transactable` with `deposit` and `withdraw` methods.

### Solution Sketch
```dart
mixin Transactable {
  double _balance = 0.0;
  double get balance => _balance;

  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    _balance += amount;
  }

  void withdraw(double amount);
}

abstract class BankAccount with Transactable {
  final String owner;
  BankAccount(this.owner);
}

class SavingsAccount extends BankAccount {
  final double interestRate;
  SavingsAccount(String owner, this.interestRate) : super(owner);

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    if (_balance - amount < 0) throw Exception('Insufficient funds');
    _balance -= amount;
  }

  void applyInterest() => _balance += _balance * interestRate;
}

class CheckingAccount extends BankAccount {
  final double overdraftLimit;
  CheckingAccount(String owner, this.overdraftLimit) : super(owner);

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    if (_balance - amount < -overdraftLimit) {
      throw Exception('Overdraft limit exceeded');
    }
    _balance -= amount;
  }
}
```

---

# 📅 Day 6 — Async Programming (Futures & Streams)

## ⏳ Topic: Futures, `async`/`await`, and Error Handling

### Concept
- **`Future<T>`** represents a value that will be available later.
- **`async`** marks a function as asynchronous, allowing `await`.
- **`await`** pauses execution until the Future completes.
- Use `try/catch` to handle errors in async code.

### Code Examples
```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded';
}

void main() async {
  try {
    print('Loading...');
    var data = await fetchData();
    print(data);
  } catch (e) {
    print('Error: $e');
  }
}
```

### External Reference
- [Dart Asynchronous Programming: Futures](https://dart.dev/libraries/async/futures)

### ✅ Check-in Quiz
**Q:** What does `await` do?
A) Makes the entire program wait.  
B) Pauses the current function until the Future completes.  
C) Immediately returns the value.  
D) Cancels the Future.

<details><summary>Answer</summary>
B) It pauses only the async function, not the whole program.
</details>

---

## 🌊 Topic: Streams, `async*`, `await for`, and Controllers

### Concept
- **`Stream<T>`** is an asynchronous sequence of events.
- **`async*`** function can `yield` multiple values over time.
- **`await for`** loops over a stream.
- **`StreamController`** creates custom streams.

### Code Examples
```dart
Stream<int> countDown(int from) async* {
  for (int i = from; i > 0; i--) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}

void main() async {
  await for (var value in countDown(3)) {
    print(value);
  }
  print('Done!');
}
```

### External Reference
- [Dart Asynchronous Programming: Streams](https://dart.dev/libraries/async/using-streams)

### ✅ Check-in Quiz
**Q:** What is the output of:
```dart
Stream<int> numbers() async* {
  yield 1;
  yield 2;
}
void main() async {
  await for (var n in numbers()) {
    print(n);
  }
}
```
A) `1` `2`  
B) Nothing  
C) `1`  
D) Compilation error

<details><summary>Answer</summary>
A) `1` `2`. The stream yields both values.
</details>

---

## 📉 Practice: Download Progress Tracker

### Goal
Simulate a download using a `Stream` that emits progress percentages.

### Solution
```dart
import 'dart:async';

Stream<int> downloadProgress() async* {
  for (int i = 0; i <= 100; i += 10) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}

void main() async {
  print('Download started');
  await for (var percent in downloadProgress()) {
    print('$percent% complete');
  }
  print('Download finished');
}
```

---

# 📅 Day 7 — Isolates, Functional Programming & Core Libraries

## 🧵 Topic: Isolates — Concurrency in Dart

### Concept
- **Isolates** run independent code with separate memory (no shared state).
- Communicate via ports (`SendPort`, `ReceivePort`).
- Use `Isolate.spawn()` to start a new isolate.
- In Flutter, `compute()` is a simpler wrapper.

### Code Example (CLI)
```dart
import 'dart:isolate';

void heavyTask(SendPort sendPort) {
  // Simulate heavy work
  var result = 0;
  for (int i = 0; i < 1000000000; i++) {
    result += i;
  }
  sendPort.send(result);
}

void main() async {
  var receivePort = ReceivePort();
  await Isolate.spawn(heavyTask, receivePort.sendPort);
  var result = await receivePort.first;
  print('Result from isolate: $result');
}
```

### External Reference
- [Dart Isolates](https://dart.dev/language/concurrency)

### ✅ Check-in Quiz
**Q:** Why use isolates instead of threads?
A) Isolates share memory, making communication faster.  
B) Isolates are lighter and have no shared memory, avoiding race conditions.  
C) Isolates are the only way to do async.  
D) Dart doesn’t have threads.

<details><summary>Answer</summary>
B) Isolates have no shared memory, so data races are impossible.
</details>

---

## 🧪 Topic: Functional Programming Patterns (Higher‑order functions, Immutability)

### Concept
- **Higher‑order functions**: functions that take or return functions.
- **Immutability**: avoid mutable state; use `final` and collection methods that return new collections.
- Common patterns: `map`, `where` (filter), `reduce`, `fold`.

### Code Examples
```dart
void main() {
  var numbers = [1, 2, 3, 4, 5];

  // Filter + map
  var squaredEvens = numbers
      .where((n) => n.isEven)
      .map((n) => n * n)
      .toList();
  print(squaredEvens); // [4, 16]

  // Reduce
  var sum = numbers.reduce((a, b) => a + b);
  print(sum); // 15

  // Fold with accumulator (can return different type)
  var sumString = numbers.fold('', (acc, n) => '$acc$n');
  print(sumString); // "12345"
}
```

### External Reference
- [Dart Functional Programming](https://dart.dev/guides/language/language-tour#functions)

### ✅ Check-in Quiz
**Q:** Which is NOT a higher‑order function?
A) `List.map()`  
B) `List.where()`  
C) `List.length`  
D) `List.fold()`

<details><summary>Answer</summary>
C) `length` is a getter, not a function that takes another function.
</details>

---

## 📚 Topic: Core Libraries (`dart:core`, `dart:math`, `dart:convert`, `dart:io`)

### Concept
- **`dart:core`**: `String`, `DateTime`, `Duration`, `RegExp`, `StringBuffer`.
- **`dart:math`**: `Random`, `min`, `max`, `sqrt`, trigonometric functions.
- **`dart:convert`**: JSON and base64 encoding/decoding.
- **`dart:io`**: file I/O, HTTP, sockets (CLI/server).

### Code Examples
```dart
import 'dart:math';
import 'dart:convert';
import 'dart:io';

void main() {
  // dart:math
  var random = Random();
  print(random.nextInt(100));

  // dart:convert
  var jsonString = '{"name":"Dart","year":2024}';
  var data = jsonDecode(jsonString) as Map<String, dynamic>;
  print(data['name']); // Dart

  // dart:io (write to file)
  var file = File('example.txt');
  file.writeAsStringSync('Hello, Dart!');
  print(file.readAsStringSync());
}
```

### External Reference
- [Dart Core Libraries](https://dart.dev/guides/libraries)

### ✅ Check-in Quiz
**Q:** Which library provides `jsonDecode`?
A) `dart:core`  
B) `dart:json`  
C) `dart:convert`  
D) `dart:io`

<details><summary>Answer</summary>
C) `dart:convert`.
</details>

---

## 📊 Practice: Parse JSON into Dart Objects

### Goal
Read a JSON string containing a list of people and convert it into Dart objects using `dart:convert`.

### Solution
```dart
import 'dart:convert';

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  @override
  String toString() => 'Person(name: $name, age: $age)';
}

void main() {
  String jsonString = '''
  [
    {"name": "Alice", "age": 30},
    {"name": "Bob", "age": 25}
  ]
  ''';

  List<dynamic> jsonList = jsonDecode(jsonString);
  List<Person> people = jsonList.map((json) => Person(json['name'], json['age'])).toList();

  for (var person in people) {
    print(person);
  }
}
```

---

# 📅 Day 8 — Dart 3 Features + Null Safety Review + Mini‑Project

## 🎁 Topic: Records, Destructuring, and Pattern Matching

### Concept
- **Records**: lightweight anonymous data containers with positional or named fields.
- **Destructuring**: extract values from records or other structures.
- **Pattern matching** in `switch` (including guards) for exhaustive checks.

### Code Examples
```dart
void main() {
  // Record with positional fields
  var record = (42, 'answer', true);
  print(record.$1); // 42

  // Destructuring
  var (num, text, flag) = record;
  print('$num, $text, $flag');

  // Named record
  var user = (name: 'Alice', age: 30);
  print(user.name); // Alice

  // Pattern matching with guard
  var obj = 5;
  switch (obj) {
    case int n when n > 10:
      print('Large int');
    case int n:
      print('Small int: $n');
    default:
      print('Not an int');
  }
}
```

### External Reference
- [Dart 3: Records](https://dart.dev/language/records)
- [Patterns](https://dart.dev/language/patterns)

### ✅ Check-in Quiz
**Q:** What does destructuring allow?
A) To break a record into its components.  
B) To create new records.  
C) To make classes private.  
D) To clone objects.

<details><summary>Answer</summary>
A) Destructuring extracts fields into individual variables.
</details>

---

## 🔒 Topic: Null Safety Mastery

### Concept
- **Sound null safety**: prevents `null` dereference at compile time.
- **Non‑nullable types** cannot be `null`; nullable types have `?`.
- **`late`** for non‑nullable variables that are set after initialization.
- **`required`** for named parameters that must be provided.
- Migration patterns: `?`, `!`, `??`, `??=`, `?.` operator.

### Code Examples
```dart
class User {
  final String name;
  String? email; // can be null
  late final int id; // will be set later

  User(this.name, {this.email});

  void setId(int newId) {
    id = newId;
  }

  String getEmail() => email ?? 'No email'; // null‑aware operator
}

void main() {
  var user = User('Alice');
  user.setId(1);
  print(user.getEmail()); // No email

  // Using null‑aware operators
  String? nullableString;
  print(nullableString?.length); // null (no error)
  String safe = nullableString ?? 'default';
  nullableString ??= 'assigned';
}
```

### External Reference
- [Dart Null Safety](https://dart.dev/null-safety)

### ✅ Check-in Quiz
**Q:** What does the `??` operator do?
A) Checks if a value is null and throws an error.  
B) Provides a default value if the left side is null.  
C) Compares two values.  
D) Casts to non‑nullable.

<details><summary>Answer</summary>
B) It returns the left operand if it's not null, otherwise the right operand.
</details>

---

## 📏 Topic: Code Quality (`dart analyze`, `dart format`, Lints)

### Concept
- **`dart analyze`**: runs static analysis to find issues.
- **`dart format`**: automatically formats code according to Dart guidelines.
- **Lints**: rules to enforce style and best practices (e.g., `package:lints` or `flutter_lints`).

### Example Commands
```bash
# Run analyzer
dart analyze

# Format all Dart files
dart format .

# Add lints to pubspec.yaml
dev_dependencies:
  lints: ^4.0.0
```

### External Reference
- [Dart Code Analysis](https://dart.dev/tools/analysis)
- [Dart Format](https://dart.dev/tools/dart-format)
- [Effective Dart](https://dart.dev/effective-dart)

---

## 🎯 Mini‑Project: Dart CLI Quiz App

### Goal
Build a terminal‑based quiz app using all concepts: sealed classes, JSON, async, immutability, and error handling.

### Solution Outline

1. **Data model** with sealed class for question types:
```dart
sealed class Question {
  final String text;
  const Question(this.text);
}

final class MultipleChoice extends Question {
  final List<String> options;
  final int correctIndex;
  MultipleChoice(super.text, this.options, this.correctIndex);
}

final class TrueFalse extends Question {
  final bool correctAnswer;
  TrueFalse(super.text, this.correctAnswer);
}
```

2. **Load questions** from a JSON string using `dart:convert`.

3. **Quiz engine** with async delay, scoring, and input handling.

4. **Main function**:
```dart
void main() async {
  print('Welcome to the Dart Quiz!');
  List<Question> questions = loadQuestions();
  int score = 0;

  for (var q in questions) {
    print('\n${q.text}');
    if (q is MultipleChoice) {
      for (var i = 0; i < q.options.length; i++) {
        print('${i + 1}. ${q.options[i]}');
      }
      int? answer;
      do {
        stdout.write('Your answer (1-${q.options.length}): ');
        var input = stdin.readLineSync();
        answer = int.tryParse(input ?? '');
      } while (answer == null || answer < 1 || answer > q.options.length);
      if (answer - 1 == q.correctIndex) score++;
    } else if (q is TrueFalse) {
      stdout.write('(t/f): ');
      var input = stdin.readLineSync()?.toLowerCase();
      bool correct = (input == 't') == q.correctAnswer;
      if (correct) score++;
    }
    await Future.delayed(Duration(milliseconds: 800));
  }

  print('\nYou scored $score out of ${questions.length}');
  print('Grade: ${score / questions.length >= 0.9 ? 'A' : score >= 0.7 ? 'B' : score >= 0.5 ? 'C' : 'F'}');
}
```

5. **Self‑review checklist** (as per curriculum):
- [ ] Can you explain null safety to someone else?
- [ ] Can you write async code without looking at the docs?
- [ ] Can you model a domain with OOP + mixins?
- [ ] Are you comfortable with collections and lambdas?

Push the project to GitHub with a README.

---

## 🎉 Congratulations!
You've completed the 5‑day structured course. You now have hands‑on experience with modern Dart (3.0+), OOP, async programming, functional patterns, and a CLI mini‑project. Keep practicing and building! 🚀