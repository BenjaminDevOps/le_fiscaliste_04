// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Analytics pour suivre le comportement utilisateur
  late FirebaseAnalytics analytics;
  // Performance monitoring
  late FirebasePerformance performance;

  // Référence à la collection 'leads'
  final CollectionReference leadsCollection = FirebaseFirestore.instance
      .collection('leads');

  // Initialisation Firebase avec toutes les fonctionnalités
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();

    // Configuration des analytics
    analytics = FirebaseAnalytics.instance;
    // Activation du monitoring de performance
    performance = FirebasePerformance.instance;

    // Optimisation du cache Firestore
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Enregistrer un nouveau lead avec tracking analytics
  Future<void> saveLead(
    Map<String, String> leadInfo,
    Map<String, String> quizResponses,
    String advice,
  ) async {
    // Trace performance pour mesurer le temps d'écriture
    final Trace trace = performance.newTrace('save_lead_trace');
    await trace.start();

    try {
      // Enregistrement dans Firestore
      final docRef = await leadsCollection.add({
        'nom': leadInfo['nom'] ?? '',
        'prenom': leadInfo['prenom'] ?? '',
        'email': leadInfo['email'] ?? '',
        'telephone': leadInfo['telephone'] ?? '',
        'quizResponses': quizResponses,
        'advice': advice,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'new',
        'plateforme': 'android', // Utile pour l'analyse
        'source': leadInfo['source'] ?? 'application', // Source d'acquisition
      });

      // Événement analytics pour mesurer la conversion
      await analytics.logEvent(
        name: 'lead_created',
        parameters: {
          'lead_id': docRef.id,
          'situation': quizResponses['situation'] ?? '',
          'revenus': quizResponses['revenus'] ?? '',
        },
      );
    } catch (e) {
      // Log erreur pour débogage
      print('Erreur enregistrement lead: $e');
      // Re-lancer l'erreur pour gestion dans l'UI
      rethrow;
    } finally {
      // Arrêter la trace performance
      await trace.stop();
    }
  }

  // Récupérer les conseils pré-établis pour réduire les appels API
  Future<Map<String, String>> getFiscalAdvice(
    Map<String, String> profile,
  ) async {
    // Cache local pour réduire les appels Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('fiscal_advice')
        .where('profile_type', isEqualTo: _determineProfileType(profile))
        .limit(1)
        .get(
          GetOptions(source: Source.serverAndCache),
        ); // Utilise le cache si disponible

    if (querySnapshot.docs.isNotEmpty) {
      return Map<String, String>.from(querySnapshot.docs.first.data() as Map);
    }

    return {'advice': 'Conseil fiscal par défaut...'};
  }

  // Déterminer le profil fiscal (logique métier)
  String _determineProfileType(Map<String, String> profile) {
    // Implémentation de la logique de profilage
    if (profile['revenus'] == '> 100 000€') {
      return 'high_income';
    } else if (profile['investissements_locatifs'] != 'Aucun') {
      return 'investor';
    }
    return 'standard';
  }
}
