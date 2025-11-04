import 'package:flutter/material.dart';
import '../api_service.dart';

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({super.key});

  @override
  State<AddQuizPage> createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";

  List<Map<String, dynamic>> questions = [
    {
      'question_text': '',
      'options': ['', '', '', ''],
      'correct_answer': '',
    },
  ];

  ///  Add another question dynamically
  void addQuestion() {
    setState(() {
      questions.add({
        'question_text': '',
        'options': ['', '', '', ''],
        'correct_answer': '',
      });
    });
  }

  /// Submit the quiz to backend and return true on success
  Future<bool> submitQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final formattedQuestions = questions.map((q) {
      return {
        'question_text': q['question_text'].toString().trim(),
        'options': List<String>.from(
            q['options'].map((o) => o.toString().trim())),
        'correct_answer': q['correct_answer'].toString().trim(),
      };
    }).toList();

    final quizData = {
      'title': title.trim(),
      'description': description.trim(),
      'questions': formattedQuestions,
    };

    print(" Sending quiz data: $quizData");

    try {
      final success = await api.createQuiz(quizData);

      if (success) {
        if (!mounted) return false; // Avoid context issues
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Quiz added successfully!')),
        );
        Navigator.pop(context, true); // Return true after submission
        return true;
      } else {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add quiz. Try again.')),
        );
        return false;
      }
    } catch (e) {
      print("Error submitting quiz: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📝 Quiz Title
              TextFormField(
                decoration: const InputDecoration(labelText: "Quiz Title"),
                onChanged: (v) => title = v,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter quiz title" : null,
              ),
              // Description
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 20),

              // Question fields
              ...questions.asMap().entries.map((entry) {
                int index = entry.key;
                var question = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Question ${index + 1}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Question text",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => question['question_text'] = v,
                          validator: (v) => v == null || v.isEmpty
                              ? "Enter question text"
                              : null,
                        ),
                        const SizedBox(height: 10),
                        for (int i = 0; i < 4; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Option ${i + 1}",
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (v) => question['options'][i] = v,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Enter option ${i + 1}"
                                  : null,
                            ),
                          ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Correct Answer",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => question['correct_answer'] = v,
                          validator: (v) => v == null || v.isEmpty
                              ? "Enter correct answer"
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              //  Add Question Button
              ElevatedButton.icon(
                onPressed: addQuestion,
                icon: const Icon(Icons.add),
                label: const Text("Add Another Question"),
              ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  final success = await submitQuiz();
                  if (success) {
                    print(" Quiz submission successful!");
                  }
                },
                child: const Text("Submit Quiz"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
