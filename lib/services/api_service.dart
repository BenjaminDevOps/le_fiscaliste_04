/// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Client HTTP pour permettre les tests mock
  final http.Client client;

  // Clé API - à remplacer par votre clé ou utiliser dotenv
  final String apiKey =
      'votre_clé_deepseek_ici'; // Idéalement via dotenv.env['DEEPSEEK_API_KEY']

  // Constructeur avec injection de dépendance pour les tests
  ApiService({http.Client? client}) : this.client = client ?? http.Client();

  /// Génère un conseil fiscal personnalisé basé sur les réponses du quiz
  Future<String> fetchAdvice(Map<String, String> userProfile) async {
    try {
      // Vérification de la clé API
      final String apiKeyToUse = dotenv.env['DEEPSEEK_API_KEY'] ?? apiKey;

      if (apiKeyToUse.isEmpty || apiKeyToUse == 'votre_clé_deepseek_ici') {
        return _generateFallbackAdvice(userProfile);
      }

      // Création du contenu pour l'API
      String userContent = "Voici le profil fiscal de l'utilisateur :\n";
      userProfile.forEach((key, value) {
        userContent += "- $key: $value\n";
      });

      userContent +=
          "\nCrée un profil patrimonial personnalisé (ex. \"Le Stratège Fiscal\") " +
          "et fournis un conseil financier détaillé basé sur ce profil. " +
          "Suggère des optimisations fiscales et des économies potentielles en euros.";

      // Corps de la requête pour l'API Deepseek
      final Map<String, dynamic> requestBody = {
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'user', 'content': userContent},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      // Encodage du corps de la requête
      final String encodedBody = json.encode(requestBody);

      // Envoi de la requête à l'API Deepseek
      final response = await client.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKeyToUse',
          'Content-Type': 'application/json',
        },
        body: encodedBody,
      );

      // Traitement de la réponse
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('choices') &&
            jsonResponse['choices'].isNotEmpty &&
            jsonResponse['choices'][0].containsKey('message') &&
            jsonResponse['choices'][0]['message'].containsKey('content')) {
          return jsonResponse['choices'][0]['message']['content'];
        }
        throw Exception('Format de réponse API inattendu');
      } else {
        // En cas d'erreur API, utiliser la génération locale de secours
        return _generateFallbackAdvice(userProfile);
      }
    } catch (e) {
      print('Erreur API: $e');
      // En cas d'erreur, utiliser la génération locale
      return _generateFallbackAdvice(userProfile);
    }
  }

  /// Méthode de secours pour générer un conseil sans API
  String _generateFallbackAdvice(Map<String, String> responses) {
    // Création d'un profil fiscal personnalisé
    String profileName = _getProfileName(responses);

    // Conseil personnalisé basé sur les réponses
    String advice = '$profileName\n\n';

    // Situation familiale
    String situation = responses['situation'] ?? '';
    if (situation.isNotEmpty) {
      if (situation == 'Marié(e)' || situation == 'Pacsé(e)') {
        advice +=
            'En tant que ${situation.toLowerCase()}, vous bénéficiez du quotient familial. Cela permet de diviser votre revenu imposable, potentiellement réduisant votre taux d\'imposition marginal. ';
      } else if (situation == 'Divorcé(e)') {
        advice +=
            'Suite à votre divorce, assurez-vous que la répartition des avantages fiscaux liés aux enfants est optimisée. La pension alimentaire versée est déductible de vos revenus. ';
      } else if (situation == 'Célibataire') {
        advice +=
            'En tant que célibataire, vous pouvez optimiser votre fiscalité en investissant dans un PER qui vous permettra de déduire vos versements de votre revenu imposable. ';
      }
    }

    // Revenus
    String revenus = responses['revenus'] ?? '';
    if (revenus.isNotEmpty) {
      if (revenus.contains('< 25 000€')) {
        advice +=
            'Avec vos revenus actuels, vous pourriez être éligible à certains crédits d\'impôts comme celui pour l\'emploi d\'un salarié à domicile. Économie potentielle: 1.200€ par an. ';
      } else if (revenus.contains('25 000€ - 50 000€')) {
        advice +=
            'Votre niveau de revenus vous permet d\'envisager un investissement dans un PER avec une déduction fiscale potentielle de 3.800€. ';
      } else if (revenus.contains('50 000€ - 75 000€')) {
        advice +=
            'Dans votre tranche de revenus, l\'investissement locatif en Pinel pourrait vous faire économiser jusqu\'à 6.000€ d\'impôts annuels. ';
      } else if (revenus.contains('75 000€ - 100 000€') ||
          revenus.contains('> 100 000€')) {
        advice +=
            'Avec vos revenus élevés, une stratégie diversifiée combinant FCPI (réduction d\'impôt de 25% du montant investi) et immobilier défiscalisant pourrait réduire significativement votre pression fiscale. Économie potentielle: 10.000-15.000€. ';
      }
    }

    // Propriété
    String proprietaire = responses['propriétaire'] ?? '';
    if (proprietaire == 'Oui') {
      advice +=
          'En tant que propriétaire, les travaux de rénovation énergétique peuvent vous faire bénéficier de MaPrimeRénov\' et du crédit d\'impôt pour la transition énergétique, jusqu\'à 8.000€ d\'économies. ';
    } else if (proprietaire == 'Non') {
      advice +=
          'L\'acquisition d\'une résidence principale vous permettrait de déduire les intérêts d\'emprunt dans certains cas et de constituer un patrimoine. ';
    }

    // Investissements locatifs
    String investissementsLocatifs =
        responses['investissements_locatifs'] ?? '';
    if (investissementsLocatifs.contains('1 bien') ||
        investissementsLocatifs.contains('2 à 3 biens')) {
      advice +=
          'Pour vos biens locatifs, optez pour le régime réel d\'imposition qui permet de déduire charges, travaux et intérêts d\'emprunt. Envisagez une SCI pour optimiser la transmission. ';
    } else if (investissementsLocatifs.contains('4 biens')) {
      advice +=
          'Avec plusieurs biens locatifs, la création d\'une société à l\'IS pourrait être avantageuse fiscalement, notamment pour réinvestir les loyers sans imposition immédiate. ';
    }

    // Placements
    String placements = responses['placements'] ?? '';
    if (placements.contains('Assurance vie')) {
      advice +=
          'Votre assurance-vie est idéale pour la transmission (jusqu\'à 152.500€ par bénéficiaire exonérés de droits). Assurez-vous d\'optimiser l\'allocation d\'actifs selon votre profil de risque. ';
    } else if (placements.contains('PEA')) {
      advice +=
          'Votre PEA bénéficie d\'une fiscalité avantageuse après 5 ans. Maximisez vos versements annuels pour profiter pleinement de cet avantage. ';
    }

    // Objectif
    String objectif = responses['objectif'] ?? '';
    if (objectif.contains('Réduire l\'impôt')) {
      advice +=
          'Pour réduire directement votre impôt sur le revenu, je vous recommande d\'explorer les SCPI fiscales Pinel ou Malraux qui peuvent offrir des réductions d\'impôt importantes. ';
    } else if (objectif.contains('transmission')) {
      advice +=
          'Pour optimiser votre transmission patrimoniale, combinez donation, démembrement de propriété et assurance-vie pour minimiser les droits de succession. ';
    } else if (objectif.contains('retraite')) {
      advice +=
          'Le PER est l\'instrument idéal pour votre objectif retraite, avec une déduction fiscale à l\'entrée et une fiscalité allégée à la sortie en capital. ';
    }

    // Ajouter des conseils sur la tolérance au risque
    String risque = responses['risque'] ?? '';
    if (risque.contains('Faible')) {
      advice +=
          'Compte tenu de votre profil prudent, privilégiez les fonds euros en assurance-vie et les SCPI de rendement pour un revenu régulier avec un risque limité.';
    } else if (risque.contains('Modérée')) {
      advice +=
          'Avec votre profil équilibré, une allocation 50% sécurisée / 50% dynamique serait adaptée, en combinant fonds euros et unités de compte diversifiées.';
    } else if (risque.contains('Élevée')) {
      advice +=
          'Votre appétence pour le risque vous permet d\'envisager des placements plus dynamiques comme les FCPI/FIP ou les SCPI fiscales, avec un potentiel de rendement et d\'économies fiscales plus élevé.';
    }

    return advice;
  }

  /// Génère un profil fiscal personnalisé
  String _getProfileName(Map<String, String> responses) {
    String? situation = responses['situation'];
    String? objectif = responses['objectif'];
    String? risque = responses['risque'];

    List<String> profileTitles = [
      'Le Stratège Fiscal',
      'L\'Optimiseur Patrimonial',
      'Le Planificateur Prévoyant',
      'L\'Investisseur Éclairé',
      'Le Gestionnaire Avisé',
    ];

    // Sélection d'un titre basé sur les réponses
    String title;
    if (objectif?.contains('Réduire l\'impôt') ?? false) {
      title = 'Le Stratège Fiscal';
    } else if (objectif?.contains('transmission') ?? false) {
      title = 'L\'Optimiseur Patrimonial';
    } else if (objectif?.contains('retraite') ?? false) {
      title = 'Le Planificateur Prévoyant';
    } else if (risque?.contains('Élevée') ?? false) {
      title = 'L\'Investisseur Éclairé';
    } else {
      title = 'Le Gestionnaire Avisé';
    }

    return title;
  }
}
