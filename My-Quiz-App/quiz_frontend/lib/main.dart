import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/quiz_page.dart';
import 'screens/result_page.dart';
import 'screens/add_quiz_page.dart'; 
import 'api_service.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),

      // Initial screen
      home: const HomePage(),

      // Named routes 
      routes: {
        '/home': (context) => const HomePage(),
        '/add_quiz': (context) => const AddQuizPage(),
        '/result': (context) => const ResultPage(score: 0, total: 0), 
      },
    );
  }
}
