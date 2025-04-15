import 'package:flutter/material.dart';
import 'package:le_fiscaliste_04/pages/home_page.dart';
import 'package:le_fiscaliste_04/pages/quiz_page.dart';
import 'package:le_fiscaliste_04/pages/lead_form_page.dart';
import 'package:le_fiscaliste_04/pages/result_page.dart';

class FiscalisteApp extends StatelessWidget {
  const FiscalisteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Fiscaliste',
      theme: ThemeData(
        primaryColor: const Color(0xFF0F4C75),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C75)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/quiz': (context) => const QuizPage(),
        '/lead-form':
            (context) => const LeadFormPage(advice: '', quizResponses: {}),
        '/result': (context) => const ResultPage(advice: ''),
      },
    );
  }
}
