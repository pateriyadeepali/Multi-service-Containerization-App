class Quiz {
  final int? id; // make optional for new quiz creation
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({
    this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  // From JSON (for reading from backend)
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => Question.fromJson(q))
              .toList()
          : [],
    );
  }

  // To JSON (for sending to backend when creating quiz)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final int? id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question({
    this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  //  From JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'] ?? '',
      options: (json['options'] as List).map((opt) => opt.toString()).toList(),
      correctAnswer: json['correct_answer'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
    };
  }
}
