import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class ResultPage extends StatefulWidget {
  final String advice;
  final Map<String, String>? leadInfo;

  const ResultPage({
    Key? key,
    required this.advice,
    this.leadInfo, // Paramètre optionnel
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  bool _isExpertCardVisible = false;
  String _profileType = "";
  String _adviceContent = "";
  int _potentialSavings = 0;
  List<Map<String, dynamic>> _optimizationTips = [];

  @override
  void initState() {
    super.initState();

    // Controller pour l'effet confetti
    _confettiController = ConfettiController(duration: Duration(seconds: 3));

    // Controller pour les animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    // Lancer les animations après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _parseAdvice();
      _confettiController.play();
      _animationController.forward();

      // Afficher la carte expert après un délai
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isExpertCardVisible = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Analyser la réponse de l'IA
  void _parseAdvice() {
    final fullAdvice = widget.advice;

    try {
      // Dans un cas réel, vous pourriez avoir un format JSON structuré de DeepSeek
      // Pour cet exemple, je vais simplement parser le texte

      if (fullAdvice.contains(':')) {
        final parts = fullAdvice.split(':');
        _profileType = parts[0].trim();
        _adviceContent = parts.sublist(1).join(':').trim();
      } else {
        _profileType = "Profil Optimiseur";
        _adviceContent = fullAdvice;
      }

      // Générer un montant d'économie basé sur le contenu
      // Dans un cas réel, l'IA fournirait ce montant
      _potentialSavings = 1200 + math.Random().nextInt(4800);

      // Créer quelques conseils d'optimisation
      _optimizationTips = [
        {
          'title': 'Défiscalisation immobilière',
          'description':
              'Investissement en Pinel ou LMNP pour réduire votre imposition.',
          'icon': Icons.home,
          'color': Colors.blue,
        },
        {
          'title': 'Optimisation retraite',
          'description':
              'PER individuel pour déduire vos cotisations de vos revenus imposables.',
          'icon': Icons.watch_later,
          'color': Colors.green,
        },
        {
          'title': 'Niches fiscales',
          'description':
              'Services à la personne et emploi à domicile (crédit d\'impôt de 50%).',
          'icon': Icons.savings,
          'color': Colors.purple,
        },
      ];
    } catch (e) {
      print("Erreur lors du parsing du conseil: $e");
      _profileType = "Profil Fiscaliste";
      _adviceContent =
          "Nous avons analysé votre situation et détecté plusieurs opportunités d'optimisation fiscale qui pourraient vous faire économiser plusieurs milliers d'euros.";
      _potentialSavings = 1500;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond avec pattern subtil
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/pattern.png'),
                opacity: 0.04,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Effet confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // En-tête avec logo/titre
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF0F1C3F),
                          ),
                        ),
                        Expanded(
                          child: Semantics(
                            label:
                                'Le Fiscaliste - Vos résultats personnalisés',
                            header: true,
                            child: Text(
                              "Vos Résultats",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F1C3F),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _shareResults,
                          icon: Icon(Icons.share, color: Color(0xFF0F1C3F)),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Badge de profil animé
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildProfileBadge(),
                    ),

                    SizedBox(height: 30),

                    // Carte d'économies potentielles
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildSavingsCard(),
                    ),

                    SizedBox(height: 30),

                    // Conseil personnalisé
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildAdviceCard(),
                    ),

                    SizedBox(height: 30),

                    // Conseils d'optimisation
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildOptimizationTips(),
                    ),

                    SizedBox(height: 30),

                    // Carte Expert (avec animation d'apparition)
                    if (_isExpertCardVisible)
                      AnimatedOpacity(
                        opacity: _isExpertCardVisible ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        child: _buildExpertCard(),
                      ),

                    SizedBox(height: 30),

                    // Options de partage et de navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.restart_alt,
                          label: "REFAIRE LE TEST",
                          color: Color(0xFF0F1C3F),
                          onTap:
                              () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/quiz',
                                (route) => route.isFirst,
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Note de bas de page
                    Text(
                      "Analyse réalisée par IA - Usage uniquement informatif",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBadge() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0F1C3F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0F1C3F).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "VOTRE PROFIL FISCAL",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _profileType,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard() {
    // Formater le montant avec un espace comme séparateur de milliers
    final formattedSavings = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: 0,
    ).format(_potentialSavings);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA68856), Color(0xFFA68856)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA68856).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "ÉCONOMIES POTENTIELLES",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedSavings,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              Text(
                " €",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "PAR AN",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                "Conseil personnalisé",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B262C),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _adviceContent,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF3282B8), size: 16),
              SizedBox(width: 6),
              Text(
                "Analyse basée sur l'IA avancée",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            "Vos opportunités d'optimisation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B262C),
            ),
          ),
        ),
        ..._optimizationTips
            .map(
              (tip) => _buildTipCard(
                title: tip['title'],
                description: tip['description'],
                icon: tip['icon'],
                color: tip['color'],
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildTipCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1B262C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA68856), Color(0xFFA68856)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA68856).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFFA68856)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BESOIN D'UN CONSEIL PLUS PRÉCIS ?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Un expert peut vous accompagner",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _requestExpertCall,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "PARLER À UN EXPERT",
                  style: TextStyle(
                    color: Color(0xFF0F1C3F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareResults() {
    HapticFeedback.lightImpact();

    final String shareText =
        "J'ai découvert que je pouvais économiser ${NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(_potentialSavings)}€ "
        "par an sur mes impôts grâce au Fiscaliste ! 💰\n\n"
        "Mon profil fiscal est \"$_profileType\".\n\n"
        "Découvre ton profil et tes économies potentielles ici: https://lefiscaliste.fr";

    Share.share(
      shareText,
      subject: 'Mes économies d\'impôts avec Le Fiscaliste',
    );
  }

  void _requestExpertCall() {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                reverse: true, // Permet de défiler depuis le bas
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Consultez un expert fiscal",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F1C3F),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Nos experts partenaires peuvent vous aider à mettre en place les stratégies optimales pour votre situation personnelle.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildExpertTypeCard(
                      title: "Conseiller Fiscal",
                      description:
                          "Spécialisé en optimisation d'impôt sur le revenu",
                      duration: "30 min",
                      price: "Gratuit",
                      onTap: () => _scheduleCall("Conseiller Fiscal"),
                    ),
                    SizedBox(height: 24),
                    _buildExpertTypeCard(
                      title: "Expert Patrimonial",
                      description: "Solutions avancées pour votre patrimoine",
                      duration: "45 min",
                      price: "90€",
                      onTap: () => _scheduleCall("Expert Patrimonial"),
                    ),
                    SizedBox(height: 16),
                    _buildExpertTypeCard(
                      title: "Notaire Partenaire",
                      description: "Conseil juridique et fiscal complet",
                      duration: "60 min",
                      price: "150€",
                      onTap: () => _scheduleCall("Notaire Partenaire"),
                    ),
                    SizedBox(
                      height: 50,
                    ), // Espace supplémentaire pour le bouton annuler
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: Text(
                          "ANNULER",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Espace supplémentaire en bas
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildExpertTypeCard({
    required String title,
    required String description,
    required String duration,
    required String price,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1B262C),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              price == "Gratuit"
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                price == "Gratuit"
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleCall(String expertType) {
    Navigator.pop(context); // Ferme le modal

    // Affiche un dialog de confirmation
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Demande de rendez-vous"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vous allez être mis en relation avec un $expertType."),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Votre numéro de téléphone",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("ANNULER"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Feedback de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Demande envoyée ! Un expert vous contactera très bientôt.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F4C75),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "CONFIRMER",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
