import 'package:flutter/material.dart';
import 'package:le_fiscaliste_04/pages/lead_form_page.dart';
import 'package:le_fiscaliste_04/services/api_service.dart';
import 'package:le_fiscaliste_04/utils/seo_wrapper.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Liste des questions du quiz
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quelle est votre situation familiale ?',
      'options': [
        'Célibataire',
        'Marié(e)',
        'Pacsé(e)',
        'Divorcé(e)',
        'Veuf(ve)',
      ],
      'key': 'situation',
    },
    {
      'question': 'Combien d\'enfants avez-vous à charge ?',
      'options': ['0', '1', '2', '3', '4 ou plus'],
      'key': 'enfants',
    },
    {
      'question': 'Dans quelle tranche de revenu annuel vous situez-vous ?',
      'options': [
        '< 25 000€',
        '25 000€ - 50 000€',
        '50 000€ - 75 000€',
        '75 000€ - 100 000€',
        '> 100 000€',
      ],
      'key': 'revenus',
    },
    {
      'question': 'Êtes-vous propriétaire de votre résidence principale ?',
      'options': ['Oui', 'Non', 'En cours d\'acquisition'],
      'key': 'propriétaire',
    },
    {
      'question': 'Avez-vous des investissements immobiliers locatifs ?',
      'options': ['Aucun', '1 bien', '2 à 3 biens', '4 biens ou plus'],
      'key': 'investissements_locatifs',
    },
    {
      'question': 'Avez-vous des placements financiers ?',
      'options': [
        'Non',
        'Livrets d\'épargne',
        'Assurance vie',
        'PEA',
        'Multiples placements',
      ],
      'key': 'placements',
    },
    {
      'question':
          'Êtes-vous entrepreneur ou exercez-vous une profession libérale ?',
      'options': ['Oui', 'Non'],
      'key': 'entrepreneur',
    },
    {
      'question': 'Avez-vous déjà réalisé des investissements défiscalisants ?',
      'options': ['Jamais', 'SCPI', 'FCPI/FIP', 'Loi Pinel', 'Autres'],
      'key': 'defiscalisation',
    },
    {
      'question': 'Votre objectif principal en matière fiscale ?',
      'options': [
        'Réduire l\'impôt sur le revenu',
        'Optimiser la transmission patrimoniale',
        'Développer votre patrimoine',
        'Préparer votre retraite',
      ],
      'key': 'objectif',
    },
    {
      'question':
          'Quelle est votre tolérance au risque pour les investissements ?',
      'options': [
        'Faible - Sécurité avant tout',
        'Modérée - Équilibre rendement/risque',
        'Élevée - Prêt à prendre des risques pour des rendements supérieurs',
      ],
      'key': 'risque',
    },
  ];

  // Index de la question actuelle
  int _currentQuestionIndex = 0;

  // Stockage des réponses
  Map<String, String> _userResponses = {};

  // État de chargement
  bool _isLoading = false;

  // Progress bar
  double get _progressValue => (_currentQuestionIndex + 1) / _questions.length;

  // Couleur principale de l'application
  final Color _primaryColor = Color(0xFF0F1C3F);

  // Passer à la question suivante
  void _nextQuestion(String selectedOption) {
    // Enregistrer la réponse
    setState(() {
      _userResponses[_questions[_currentQuestionIndex]['key']] = selectedOption;

      // Passer à la question suivante ou générer les résultats
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _generateResults();
      }
    });
  }

  // Revenir à la question précédente
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // Générer les résultats
  Future<void> _generateResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ApiService apiService = ApiService();
      final String advice = await apiService.fetchAdvice(_userResponses);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    LeadFormPage(advice: advice, quizResponses: _userResponses),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Question actuelle
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Questionnaire fiscal',
          style: TextStyle(
            color: Colors.white, // Couleur blanche pour le texte
            fontWeight: FontWeight.bold, // Optionnel: rend le texte en gras
          ),
        ),
        backgroundColor: Color(0xFFA68856),
        leading:
            _currentQuestionIndex > 0
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousQuestion,
                )
                : IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _primaryColor),
                    SizedBox(height: 20),
                    Text(
                      'Génération de votre conseil fiscal personnalisé...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Barre de progression
                  LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    minHeight: 8,
                  ),

                  // Compteur de questions
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),

                  // Question
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SeoText(
                      currentQuestion['question'],
                      tag: 'h2',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Options de réponse
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: currentQuestion['options'].length,
                      itemBuilder: (context, index) {
                        final option = currentQuestion['options'][index];
                        final isSelected =
                            _userResponses[currentQuestion['key']] == option;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ElevatedButton(
                            onPressed: () => _nextQuestion(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isSelected ? Colors.white : _primaryColor,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? _primaryColor : Colors.white,
                              foregroundColor:
                                  isSelected ? Colors.white : _primaryColor,
                              side: BorderSide(
                                color: _primaryColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bouton navigation (pour la dernière question)
                  if (_currentQuestionIndex == _questions.length - 1 &&
                      _userResponses.containsKey(
                        _questions[_currentQuestionIndex]['key'],
                      ))
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: _generateResults,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'OBTENIR MES RÉSULTATS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
