import 'package:flutter/material.dart';
import 'package:le_fiscaliste_04/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

// Import conditionnel pour les fonctions d'initialisation
import 'package:le_fiscaliste_04/utils/web_initializer.dart'
    if (dart.library.io) 'package:le_fiscaliste_04/utils/no_web_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement des variables d'environnement
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  // Initialisation spécifique à la plateforme
  initializeWebApp(); // Cette fonction est définie différemment selon la plateforme

  runApp(const FiscalisteApp());
}
