import 'dart:developer';

import 'package:ui_trivia/model/question_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionRepository{

static  Future<List<QuestionModel>> getQuestions({String? category, String? difficulty, int amount = 10}) async {

    final String? codeCategory = categoryList.entries.where((m) => m.value == category ).first.key.toString();

    var queryParameters = {
      'amount': amount.toString(),
      if (category != null) 'category': codeCategory,
      if (difficulty != null) 'difficulty': difficulty,
    };

    final uri = Uri.parse('http://localhost:8080/api/questions').replace(queryParameters: queryParameters);

    final response = await http.get(uri, );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['questions'] as List)
            .map((q) => QuestionModel.fromJson(q))
            .toList();
      } else {
        log("Failed to load questions");
        throw Exception('Failed to load questions');
      }
    } else {
      log("Error: ${response.statusCode}");
      throw Exception('Failed to load questions');
    }
  }


static final Map<String, String> categoryList = {
  "23": "History",
  "15": "Entertainment: Video Games",
  "9": "General Knowledge",
  "25": "Art"
};

}