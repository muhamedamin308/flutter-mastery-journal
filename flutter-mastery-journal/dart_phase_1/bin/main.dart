import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

// ============================================================
// Logger Class Configuration
// ============================================================

void setupLogging() {
  Logger.root.level = Level.ALL; // Set to INFO for production
  Logger.root.onRecord.listen((record) {
    final color = _getColorForLevel(record.level);
    final levelStr = record.level.name.padRight(7);
    final message = '${color}[$levelStr] ${record.message}${_resetColor()}';

    if (record.error != null) {
      print('$message\n${record.error}');
      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    } else {
      print(message);
    }
  });
}

String _getColorForLevel(Level level) {
  if (level == Level.SEVERE) return '\x1B[31m'; // Red
  if (level == Level.WARNING) return '\x1B[33m'; // Yellow
  if (level == Level.INFO) return '\x1B[32m'; // Green
  if (level == Level.CONFIG) return '\x1B[36m'; // Cyan
  if (level == Level.FINE) return '\x1B[90m'; // Gray
  return '\x1B[0m'; // Reset
}

String _resetColor() => '\x1B[0m';

// ============================================================
// DOMAIN MODELS — Sealed class hierarchy for question types
// ============================================================

sealed class Question {
  final String id;
  final String text;
  final int points;

  const Question({required this.id, required this.text, required this.points});

  factory Question.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'multiple_choice' => MultipleChoice.fromJson(json),
      'true_false' => TrueFalse.fromJson(json),
      _ => throw ParseException('unknown question type: $type'),
    };
  }

  bool checkAnswer(String answer);
  String get formattedQuestion;
}

class MultipleChoice extends Question {
  final List<String> options;
  final String correctOption; // A, B, C or D

  const MultipleChoice({
    required super.id,
    required super.text,
    required super.points,
    required this.options,
    required this.correctOption,
  });

  factory MultipleChoice.fromJson(Map<String, dynamic> json) {
    return MultipleChoice(
      id: json['id'] as String,
      text: json['text'] as String,
      points: json['points'] as int,
      options: (json['options'] as List<dynamic>).cast<String>(),
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
      buffer.writeln('   ${labels[i]}) ${options[i]}');
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
      id: json['id'] as String,
      text: json['text'] as String,
      points: json['points'] as int,
      correctAnswer: json['correct'] as bool,
    );
  }

  @override
  bool checkAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    return switch (normalized) {
      'true' || 't' || 'yes' => correctAnswer == true,
      'false' || 'f' || 'no' => correctAnswer == false,
      _ => false,
    };
  }

  @override
  String get formattedQuestion => '$text\n (Enter: true/false)';
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
  String toString() => 'InvalidInpit("$input"): $reason';
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
    this.score = 0,
    this.totalPoints = 0,
    this.answers = const [],
  });

  QuizState recordAnswer({
    required String questionId,
    required bool correct,
    required int points,
  }) {
    return QuizState(
      currentIndex: currentIndex + 1,
      score: correct ? score + points : score,
      totalPoints: totalPoints + points,
      answers: [...answers, (questionId, correct)],
    );
  }

  double get percentage => totalPoints == 0 ? 0 : (score / totalPoints) * 100;

  String get grade => switch (percentage) {
    >= 90 => 'A',
    >= 80 => 'B',
    >= 70 => 'C',
    >= 60 => 'D',
    _ => 'F',
  };
}

// ============================================================
// QUIZ ENGINE
// ============================================================

class QuizEngine {
  final List<Question> questions;
  final Logger _logger = Logger('QuizEngine'); // Add logger instance

  QuizEngine(this.questions);

  factory QuizEngine.fromJsonString(String jsonStr) {
    final logger = Logger('QuizEngine');
    try {
      logger.fine('Parsing JSON quiz data'); // FINE for detailed info
      final data = jsonDecode(jsonStr) as List<dynamic>;
      final questions = data
          .cast<Map<String, dynamic>>()
          .map(Question.fromJson)
          .toList();
      if (questions.isEmpty) {
        logger.severe('No questions found in JSON'); // SEVERE for errors
        throw ParseException('No questions found in JSON');
      }
      logger.info(
        'Successfully loaded ${questions.length} questions',
      ); // INFO for normal flow
      return QuizEngine(questions);
    } on FormatException catch (e) {
      logger.severe('Invalid JSON format', e); // Log error with exception
      throw ParseException('Invalid JSON format: ${e.message}');
    }
  }

  Future<QuizState> run() async {
    final logger = Logger('QuizEngine.run');
    var state = const QuizState();

    logger.info('Starting quiz session'); // INFO for major events
    _printHeader();

    for (final question in questions) {
      state = await _askQuestion(question, state);
    }

    logger.info('Quiz completed successfully');
    return state;
  }

  Future<QuizState> _askQuestion(Question question, QuizState state) async {
    final logger = Logger('QuizEngine._askQuestion');

    // Simulate question load delay
    await Future.delayed(Duration(milliseconds: 300));

    logger.finer(
      'Loading question: ${question.id}',
    ); // FINER for detailed tracing

    final questionNum = state.currentIndex + 1;

    // Replace print with INFO level
    logger.info(
      '\n--- Question $questionNum/${questions.length} [${question.points} pts] ---\n${question.formattedQuestion}',
    );

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
          logger.warning(
            'User failed to provide valid input after 3 attempts',
          ); // WARNING for recoverable issues
          answer = '__invalid__';
        } else {
          logger.config(
            'Invalid input attempt $attempts: ${e.reason}',
          ); // CONFIG for configuration issues
          print('  ❌ ${e.reason} (${3 - attempts} attempts left)');
        }
      }
    }

    final correct = question.checkAnswer(answer);

    // Log answer result
    if (correct) {
      logger.fine(
        'Correct answer for ${question.id} (+${question.points} pts)',
      ); // FINE for success details
    } else {
      logger.fine(
        'Incorrect answer for ${question.id}',
      ); // FINE for failure details
    }

    // Keep UI feedback as print (user-facing)
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
      TrueFalse() => _validateTrueFalse(input),
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
    final logger = Logger('QuizEngine._printHeader');

    // Use INFO for important UI boundaries
    logger.info('=' * 38);
    logger.info('🎯 DART QUIZ APP 🎯');
    logger.info('=' * 38);
    logger.info(
      '${questions.length} questions | ${questions.fold(0, (s, q) => s + q.points)} total points',
    );
    logger.info('=' * 38);

    // Still print for user visibility
    print('');
    print('╔══════════════════════════════════╗');
    print('║       🎯  DART QUIZ APP  🎯      ║');
    print('╠══════════════════════════════════╣');
    print(
      '║  ${questions.length} questions | ${questions.fold(0, (s, q) => s + q.points)} total points   ║',
    );
    print('╚══════════════════════════════════╝');
  }
}

// ============================================================
// RESULT PRINTER
// ============================================================

void printResults(QuizState state, List<Question> questions) {
  final logger = Logger('QuizResults');

  // Log results at INFO level
  logger.info(
    'Quiz Results - Score: ${state.score}/${state.totalPoints} (${state.percentage.toStringAsFixed(1)}%) Grade: ${state.grade}',
  );

  // Keep user-facing UI as print
  print('\n╔══════════════════════════════════╗');
  print('║           QUIZ COMPLETE!          ║');
  print('╠══════════════════════════════════╣');
  print(
    '║  Score:  ${state.score}/${state.totalPoints} pts'.padRight(35) + '║',
  );
  print('║  Grade:  ${state.grade}'.padRight(35) + '║');
  print(
    '║  Pct:    ${state.percentage.toStringAsFixed(1)}%'.padRight(35) + '║',
  );
  print('╚══════════════════════════════════╝');

  // Log detailed answer breakdown at FINE level
  logger.fine('Question breakdown:');
  for (final (id, correct) in state.answers) {
    final q = questions.firstWhere((q) => q.id == id);
    logger.finer(
      '  Question $id: ${correct ? "correct" : "incorrect"} (${correct ? "+${q.points}" : "0"})',
    );
  }

  print('\nQuestion Breakdown:');
  for (final (id, correct) in state.answers) {
    final q = questions.firstWhere((q) => q.id == id);
    final icon = correct ? '✅' : '❌';
    final pts = correct ? '+${q.points}' : '+0';
    print(
      '  $icon  [$pts pts]  ${q.text.substring(0, q.text.length.clamp(0, 50))}',
    );
  }

  final message = switch (state.grade) {
    'A' => '🏆 Outstanding! You clearly know your Dart!',
    'B' => '🎉 Great work! A bit more practice and you\'ll ace it.',
    'C' => '👍 Decent effort. Review the missed topics.',
    'D' => '📚 You passed, but there\'s room to grow.',
    _ => '💪 Don\'t give up! Review the material and try again.',
  };

  logger.info('Result message: $message');
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

void main(List<String> args) async {
  // Setup logging first
  setupLogging();
  final logger = Logger('QuizApp');

  try {
    logger.info('Initializing quiz application');
    final engine = QuizEngine.fromJsonString(quizJson);
    final finalState = await engine.run();

    logger.info('Quiz completed, displaying results');
    printResults(finalState, engine.questions);

    logger.info('Application finished successfully');
  } on ParseException catch (e) {
    logger.severe('Failed to load quiz', e);
    print('❌ Failed to load quiz: $e');
    exitCode = 1;
  } catch (e, stack) {
    logger.severe('Unexpected error occurred', e, stack);
    print('❌ Unexpected error: $e');
    print(stack);
    exitCode = 1;
  }
}
