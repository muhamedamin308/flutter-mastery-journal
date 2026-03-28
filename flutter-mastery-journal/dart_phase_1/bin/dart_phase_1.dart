import 'dart:io';

void main() {
  stdout.write('Please enter a number: ');
  String? input = stdin.readLineSync();

  double? value = double.tryParse(input ?? '0');

  if (value == null) {
    print('Error: "${input}" is not a valid number. System ended.');
    return;
  }

  print('You entered: $value');
  print('Choose conversion:\n1. KM to Miles\n2. °C to °F');
  stdout.write('Selection: ');

  String? choice = stdin.readLineSync();

  if (choice == "1") {
    double miles = value * 0.621371;
    print('${value}KM is approximately ${miles.toStringAsFixed(2)} miles.');
  } else if (choice == "2") {
    double fahrenheit = (value * 9 / 5) + 32;
    print('${value}°C is ${fahrenheit.toStringAsFixed(1)}°F.');
  } else {
    print('Invalid selection. System ended.');
  }
}
