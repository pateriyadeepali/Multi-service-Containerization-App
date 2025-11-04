import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final int quizId;

  const QuizPage({super.key, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ApiService api = ApiService();
  late Future<Quiz> quizFuture;
  Map<int, String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    quizFuture = api.getQuiz(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: FutureBuilder<Quiz>(
        future: quizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No quiz found'));
          }

          final quiz = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(quiz.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(quiz.description),
                const Divider(height: 30),

                // Display all questions
                ...quiz.questions.map((question) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quiz.questions.indexOf(question) + 1}. ${question.questionText}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),

                      // Display options
                      ...question.options.map((opt) {
                        return RadioListTile<String>(
                          title: Text(opt),
                          value: opt,
                          groupValue: selectedAnswers[
                              question.id ?? -1], // handle null id safely
                          onChanged: (value) {
                            if (question.id != null) {
                              setState(() {
                                selectedAnswers[question.id ?? -1] = value!;
                              });
                            }
                          },
                        );
                      }).toList(),
                      const Divider(),
                    ],
                  );
                }).toList(),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      print('Submitting answers: $selectedAnswers');
                      final result =
                          await api.submitQuiz(widget.quizId, selectedAnswers);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultPage(
                            score: result['score'] ?? 0,
                            total: result['total'] ?? 0,
                          ),
                        ),
                      );
                    } catch (e) {
                      print("Error submitting quiz: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Submit Quiz'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
