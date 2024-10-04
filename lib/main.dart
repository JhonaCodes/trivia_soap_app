import 'package:flutter/material.dart';


import 'package:ui_trivia/model/question_model.dart';
import 'package:ui_trivia/repository/repository.dart';
import 'package:ui_trivia/ui/game_screen.dart';

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

  final List<String> categories = QuestionRepository.categoryList.values.toList();
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
                  List<QuestionModel> questions = await QuestionRepository.getQuestions(
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






