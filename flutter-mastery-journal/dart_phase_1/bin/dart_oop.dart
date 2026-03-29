// OOP

class Temperature {
  final double celsius;

  // Default constructor with initializer list
  Temperature(this.celsius)
    : assert(celsius >= -273.15, 'Below absolute zero!');

  // Named constructors
  Temperature.fromFahrenheit(double f) : celsius = (f - 32) * 5 / 9;
  Temperature.fromKelvin(double k) : celsius = k - 273.15;
  // Const constructors
  const Temperature.absoluteZero() : celsius = -273.15;

  // Factory - caching pattern
  static final Map<double, Temperature> _cache = {};
  factory Temperature.cached(double celsius) {
    return _cache.putIfAbsent(celsius, () => Temperature(celsius));
  }

  double get fahrenheit => celsius * 9 / 5 + 32;
  double get kelvin => celsius + 273.15;

  @override
  String toString() => '${celsius.toStringAsFixed(1)}°C';
}

class Circle {
  // private mutable field
  double _radius;

  static const double pi = 3.1415926535;
  static int _instanceCount = 0;

  Circle(double redius) : _radius = redius, assert(redius > 0) {
    _instanceCount++;
  }

  // Getters
  double get redius => _radius;
  double get area => pi * _radius * _radius;
  double get circumference => 2 * pi * _radius;

  // Setters
  set redius(double value) {
    if (value <= 0) throw ArgumentError('redius must be positive');
    _radius = value;
  }

  // Static member - class-level, not per-instance
  static int get instanceCount => _instanceCount;

  @override
  String toString() => 'Circle(r=$_radius, area=${area.toStringAsFixed(2)})';
}

// Inheritance & Polymorphism
abstract class Animal {
  final String name;
  Animal(this.name);

  // Abstract method - subclass MUST override
  String makeSound();

  // Concrete method - subclass CAN override
  String describe() => '$name says: ${makeSound()}';
}

class Dog extends Animal {
  final String breed;
  Dog(super.name, this.breed);

  @override
  String makeSound() => 'WOOF!!';

  @override
  String describe() => '${super.describe()} [Breed: $breed]';
}

class Cat extends Animal {
  Cat(super.name);

  @override
  String makeSound() => 'MEOW!!';
}

// Polymorphism
void introduceAnimal(Animal a) => print(a.describe());

// OOP — abstract Classes, implements, mixin
abstract class Serizlaizable {
  Map<String, dynamic> toJson();
}

abstract class Validatable {
  List<String> validate();
  bool get isValid => validate().isEmpty;
}

// Mixin - reusable logging begaviour
mixin Loggable {
  final List<String> _log = [];
  void log(String message) {
    _log.add('[${DateTime.now()}] $message');
  }

  List<String> get logs => List.unmodifiable(_log);
}

class UserProfile with Loggable implements Serizlaizable, Validatable {
  String name;
  String email;
  int age;

  UserProfile({required this.name, required this.email, required this.age});

  @override
  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'age': age};

  @override
  List<String> validate() {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Name is required');
    if (!email.contains('@')) errors.add('Invalid Email');
    if (age < 0 || age > 150) errors.add('Invalid Age');
    return errors;
  }

  void update(String newName) {
    log('Name changed from $name to $newName');
    name = newName;
  }

  @override
  bool get isValid => validate().isEmpty;
}

// OOP — sealed Classes (Dart 3)
sealed class NetworkResult<T> {}

class Success<T> extends NetworkResult<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends NetworkResult<T> {
  final String message;
  final int statusCode;
  Failure(this.message, this.statusCode);
}

class Loading<T> extends NetworkResult<T> {
  Loading();
}

String handleResult(NetworkResult<String> result) => switch (result) {
  Success(:final data) => 'Got: $data',
  Failure(:final message, :final statusCode) => 'Error $statusCode: $message',
  Loading() => "Loading....",
};

// Advanced OOP - Enhanced Enums

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

  static Priority fromWeight(int w) => values.firstWhere(
    (p) => p.weight == w,
    orElse: () => throw ArgumentError('Unknown weight: $w'),
  );
}

// Extensions
extension StringExtenstions on String {
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  bool get isValidEmail => RegExp(r'^[\w.]+@[\w]+\.\w+$').hasMatch(this);

  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}

class SortedList<T extends Comparable> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
    _items.sort();
  }

  T get min => _items.first;
  T get max => _items.last;

  List<T> get items => List.unmodifiable(_items);
}

void main(List<String> args) {
  print('hello world muhamed'.titleCase);
  print('userxample.com'.isValidEmail);
  print('A very long string with alot of code'.truncate(18));

  final scores = SortedList<int>();
  scores.add(54);
  scores.add(92);
  scores.add(219);
  scores.add(15);
  print(scores.items);
  print('Min: ${scores.min}, Max: ${scores.max}');
}
