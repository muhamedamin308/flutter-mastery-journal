mixin Transactable {
  final List<String> _transactions = [];

  List<String> get transactions => List.unmodifiable(_transactions);

  void recordTransaction(String type, double amount, double balanceAfter) {
    _transactions.add(
      '[$type] \$${amount.toStringAsFixed(2)} -> Balance: \$${balanceAfter.toStringAsFixed(2)}',
    );
  }

  void printStatement() {
    print("--- Transaction History ---");
    for (final t in _transactions) print('  $t');
    print("--------------------------");
  }
}

abstract class Account with Transactable {
  final String accountNumber;
  final String holderName;
  double _balance;

  Account({
    required this.accountNumber,
    required this.holderName,
    required double initialBalance,
  }) : assert(initialBalance >= 0, 'Initial balance must be >= 0'),
       _balance = initialBalance;

  double get balance => _balance;

  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit must be positive');
    _balance += amount;
    recordTransaction("DEPOSIT", amount, _balance);
  }

  void withdraw(double amount);

  @override
  String toString() {
    return '$runtimeType[$accountNumber] - $holderName: \$${_balance.toStringAsFixed(2)}';
  }
}

class SavingAccount extends Account {
  final double minimumBalance;
  final double interestRate;

  SavingAccount({
    required super.accountNumber,
    required super.holderName,
    required super.initialBalance,
    this.minimumBalance = 100.0,
    this.interestRate = 0.035,
  });

  @override
  void withdraw(double amount) {
    assert(amount > 0, 'Amount must be positive');

    if (_balance - amount < minimumBalance) {
      throw StateError('Cannot go below minimum balance of \$$minimumBalance');
    }
    _balance -= amount;
    recordTransaction("WITHDRAWAL", amount, _balance);
  }

  void applyInterest() {
    double interest = _balance * interestRate;
    deposit(interest);
    recordTransaction("INTEREST", interest, _balance);
  }
}

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
      throw StateError('Cannot go below minimum balance of \$$overdraftLimit');
    }

    _balance -= amount;
    recordTransaction("WITHDRAWAL", amount, _balance);
  }
}

void main(List<String> args) {
  final saving = SavingAccount(
    accountNumber: 'SAV-001',
    holderName: 'Alice',
    initialBalance: 3382.40,
  );
  final checking = CheckingAccount(
    accountNumber: 'CHK-001',
    holderName: 'Muhammed',
    initialBalance: 500.0,
    overdraftLimit: 250.0,
  );

  saving.deposit(700.60);
  saving.withdraw(200.0);
  saving.applyInterest();

  checking.deposit(100.0);
  checking.withdraw(750.0);

  print(saving);
  saving.printStatement();

  print(checking);
  checking.printStatement();

  List<Account> accounts = [saving, checking];

  double totalAssets = accounts.fold(0.0, (sum, acc) => sum + acc.balance);

  print("Total assets: \$${totalAssets.toStringAsFixed(2)}");
}
