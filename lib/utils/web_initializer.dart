import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void initializeWebApp() {
  // Configuration web sécurisée
  try {
    // Utilisez PathUrlStrategy pour des URLs plus propres sans #
    setUrlStrategy(PathUrlStrategy());

    // Autres configurations spécifiques au web peuvent être ajoutées ici
    print('Initialisation web réussie');
  } catch (e) {
    print('Erreur lors de l\'initialisation web: $e');
    // Ne pas planter l'application en cas d'erreur
  }
}
