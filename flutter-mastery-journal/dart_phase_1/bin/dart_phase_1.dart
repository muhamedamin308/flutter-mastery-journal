import 'dart:io'; // 1. Import the Input/Output library

void main() {
  // 2. Ask the user for input
  stdout.write('Enter a number to see its multiplication table: ');

  // 3. Read the input from the terminal
  // We use '!' because readLineSync() could technically be null
  String? input = stdin.readLineSync();

  // 4. Convert the String input into an Integer
  // int.tryParse handles cases where the user types letters instead of numbers
  int? number = int.tryParse(input ?? '');

  if (number != null) {
    print('\n--- Multiplication Table for $number ---');

    for (int i = 1; i <= 10; i++) {
      print('$number x $i = ${number * i}');
    }

    print('---------------------------------------');
  } else {
    print('Invalid input! Please enter a valid whole number.');
  }
}