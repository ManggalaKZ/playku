import 'dart:math';
import 'package:math_expressions/math_expressions.dart';
import 'package:playku/core/core_game.dart';

class QuestionData {
  final String question;
  final List<double> answers;
  final double correctAnswer;

  QuestionData({
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });
}

class QuestionGenerator {
  static QuestionData generate(GameLevel level) {
    Random random = Random();
    int min, max;
    List<String> operations;

    switch (level) {
      case GameLevel.easy:
        min = 1;
        max = 10;
        operations = ['+', '-'];
        break;
      case GameLevel.medium:
        min = 10;
        max = 50;
        operations = ['+', '-', '*'];
        break;
      case GameLevel.hard:
        min = 50;
        max = 100;
        operations = ['+', '-', '*', '/'];
        break;
      default:
        throw Exception('Level tidak valid');
    }

    int a = random.nextInt(max - min + 1) + min;
    int b = random.nextInt(max - min + 1) + min;
    String operation = operations[random.nextInt(operations.length)];

    if (operation == '/' && level == GameLevel.hard) {
      b = random.nextInt(9) + 1;
      a = b * (random.nextInt(10) + 1);
    }

    String expression = '$a $operation $b';
    Parser parser = Parser();
    Expression exp = parser.parse(expression);
    ContextModel cm = ContextModel();

    double correctAnswer = exp.evaluate(EvaluationType.REAL, cm);

    Set<String> displayAnswerSet = {
      _formatAnswerForDisplay(correctAnswer, correctAnswer),
    };
    List<double> answers = [correctAnswer];

    int tries = 0;
    const int maxTries = 100;

    while (answers.length < 4 && tries < maxTries) {
      tries++;
      double offset = (random.nextDouble() * 8 - 4); 
      double fakeAnswer =
          double.parse((correctAnswer + offset).toStringAsFixed(2));
      String displayValue = _formatAnswerForDisplay(fakeAnswer, correctAnswer);

      if (_isDistinctEnough(fakeAnswer, answers, 0.3) &&
          !displayAnswerSet.contains(displayValue)) {
        answers.add(fakeAnswer);
        displayAnswerSet.add(displayValue);
      }
    }

    answers.shuffle();

    return QuestionData(
      question: expression,
      answers: answers,
      correctAnswer: correctAnswer,
    );
  }

  static String _formatAnswerForDisplay(
      double answer, double correctAnswer) {
    bool isDesimal = correctAnswer % 1 != 0;
    return isDesimal
        ? answer.toStringAsFixed(2)
        : answer.toInt().toString();
  }

  static bool _isDistinctEnough(
      double candidate, List<double> existing, double threshold) {
    for (var value in existing) {
      if ((candidate - value).abs() < threshold) {
        return false;
      }
    }
    return true;
  }
}
