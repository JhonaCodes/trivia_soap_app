import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TriviaApp());
}

class TriviaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String? selectedCategory;
  String? selectedDifficulty;
  final int questionCount = 10;

  final List<String> categories = _category.values.toList();
  final List<String> difficulties = ['easy', 'medium', 'hard'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trivia Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: selectedCategory,
              hint: Text('Select Category'),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedDifficulty,
              hint: Text('Select Difficulty'),
              items: difficulties.map((String difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDifficulty = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Start Game'),
              onPressed: () async {
                if (selectedCategory != null && selectedDifficulty != null) {
                  List<Question> questions = await getTriviasQuestions(
                    category: selectedCategory,
                    difficulty: selectedDifficulty,
                    amount: questionCount,
                  );

                  if(context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(questions: questions),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final List<Question> questions;

  GameScreen({required this.questions});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentQuestionIndex = 0;
  int score = 0;

  void answerQuestion(String selectedAnswer) {
    if (selectedAnswer == widget.questions[currentQuestionIndex].correctAnswer) {
      setState(() {
        score++;
      });
    }

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Your score: $score / ${widget.questions.length}'),
            actions: <Widget>[
              TextButton(
                child: Text('Play Again'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = widget.questions[currentQuestionIndex];
    List<String> answers = [...currentQuestion.incorrectAnswers, currentQuestion.correctAnswer];
    answers.shuffle();

    return Scaffold(
      appBar: AppBar(title: Text('Question ${currentQuestionIndex + 1}')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            currentQuestion.question,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ...answers.map((answer) =>
              ElevatedButton(
                child: Text(answer),
                onPressed: () => answerQuestion(answer),
              )
          ).toList(),
          SizedBox(height: 20),
          Text('Score: $score / ${currentQuestionIndex + 1}'),
        ],
      ),
    );
  }
}

class Question {
  final String category;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  Question({
    required this.category,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: json['category'],
      difficulty: json['difficulty'],
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }
}

Future<List<Question>> getTriviasQuestions({String? category, String? difficulty, int amount = 10}) async {

  final String? codeCategory = _category.entries.where((m) => m.value == category ).first.key.toString();

  var queryParameters = {
    'amount': amount.toString(),
    if (category != null) 'category': codeCategory,
    if (difficulty != null) 'difficulty': difficulty,
  };

  final uri = Uri.parse('http://localhost:8080/api/questions').replace(queryParameters: queryParameters);


  print(uri);

  final response = await http.get(uri, );

  print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success']) {
      return (data['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    } else {
      throw Exception('Failed to load questions');
    }
  } else {
    throw Exception('Failed to load questions');
  }
}



final Map<String, String> _category = {
  "23": "History",
  "15": "Entertainment: Video Games",
  "9": "General Knowledge",
  "25": "Art"
};