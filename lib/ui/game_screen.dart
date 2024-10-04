import 'package:flutter/material.dart';
import 'package:ui_trivia/model/question_model.dart';

class GameScreen extends StatefulWidget {
  final List<QuestionModel> questions;

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
    QuestionModel currentQuestion = widget.questions[currentQuestionIndex];
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