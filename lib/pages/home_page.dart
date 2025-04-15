import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:le_fiscaliste_04/utils/seo_wrapper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Animation du bouton principal
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Compteur d'économies qui augmente avec le temps
  int _savingsCounter = 7845329;
  Timer? _savingsTimer;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation pulsante du bouton
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Mise à jour du compteur d'économies
    _savingsTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _savingsCounter += math.Random().nextInt(5000) + 1000;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _savingsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond subtil avec motif
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/pattern.png'),
                opacity: 0.05,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),

                    // Logo et titre principal (SEO-friendly)
                    SeoText(
                      'Le Fiscaliste', // Texte visible
                      tag: 'h1', // Balise HTML (h1 pour titre principal)
                      style: TextStyle(
                        fontSize: 38, // Même taille de police
                        fontWeight: FontWeight.bold, // Même graisse
                        color: Color(0xFF0F1C3F), // Même couleur
                        letterSpacing: 1.2, // Même espacement de lettres
                      ),
                      textAlign: TextAlign.center, // Même alignement
                      // Si vous avez besoin du texte alternatif pour le SEO, ajoutez ce paramètre:
                      // seoText: 'Le Fiscaliste - Optimisation fiscale personnalisée',
                    ),

                    SizedBox(height: 10),

                    // Sous-titre (SEO-friendly)
                    Semantics(
                      label: 'Économisez sur vos impôts en 3 minutes',
                      header: true, // Indique que c'est un en-tête
                      child: Text(
                        'Économisez sur vos impôts en 3 minutes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3282B8),
                        ),
                        textAlign: TextAlign.center,
                        semanticsLabel:
                            'h2: Économisez sur vos impôts en 3 minutes', // Alternative pour indiquer le niveau h2
                      ),
                    ),

                    SizedBox(height: 40),

                    // Carte animée des économies (effet viral)
                    _buildSavingsCard(),

                    SizedBox(height: 30),

                    // Bouton principal animé
                    _buildMainButton(),

                    SizedBox(height: 15),

                    // Message de rassurance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.grey.shade600, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "3 minutes • Gratuit • Sans engagement",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 50),

                    // Témoignages
                    _buildTestimonialsSection(),

                    SizedBox(height: 40),

                    // Section experts
                    _buildExpertsSection(),

                    SizedBox(height: 40),

                    // Section avantages
                    _buildBenefitsSection(),

                    SizedBox(height: 30),

                    // CTA secondaire
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/quiz'),
                      icon: Icon(Icons.calculate_outlined),
                      label: Text("CALCULER MES ÉCONOMIES"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        side: BorderSide(color: Color(0xFF0F1C3F), width: 1.5),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Bouton de partage
                    TextButton.icon(
                      onPressed: _shareApp,
                      icon: Icon(Icons.share, color: Colors.grey.shade700),
                      label: Text(
                        "PARTAGER AVEC SES AMIS",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Carte des économies
  Widget _buildSavingsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1C3F), Color(0xFF0F4C75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0F1C3F).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "LES FRANÇAIS ONT ÉCONOMISÉ",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: '',
                  decimalDigits: 0,
                ).format(_savingsCounter),
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
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 18),
              SizedBox(width: 4),
              Text(
                "ÉCONOMIES EN TEMPS RÉEL",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget: Bouton principal animé
  Widget _buildMainButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, '/quiz');
      },
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            // Remplacez Colors.orange par la couleur personnalisée
            color: Color(0xFFA68856), // Notez le 0xFF pour l'opacité complète
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                // Corrigez également la couleur de l'ombre
                color: Color(0xFFA68856).withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
              SizedBox(width: 12),
              Text(
                "DÉCOUVRIR MES ÉCONOMIES",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Section des témoignages
  Widget _buildTestimonialsSection() {
    return Column(
      children: [
        Semantics(
          label: 'Ils ont réduit leurs impôts',
          header: true, // Indique que c'est un en-tête
          child: Text(
            'Ils ont déjà économisé',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B262C),
            ),
            textAlign: TextAlign.center,
            semanticsLabel:
                'h3: Ils ont déjà économisé', // Alternative pour indiquer le niveau h3
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: [
              _buildTestimonialCard(
                name: "Sophie L.",
                amount: "2 350 €",
                testimonial:
                    "Grâce au Fiscaliste, j'ai pu défiscaliser une partie de mes revenus locatifs !",
                profilePic: "assets/images/user1.webp",
                expertType: "Mise en relation avec un notaire",
              ),
              _buildTestimonialCard(
                name: "Marc D.",
                amount: "3 120 €",
                testimonial:
                    "Je pensais bien gérer mes impôts mais j'ai découvert des opportunités insoupçonnées !",
                profilePic: "assets/images/user2.webp",
                expertType: "Conseillé par un CGP",
              ),
              _buildTestimonialCard(
                name: "Julie M.",
                amount: "1 890 €",
                testimonial:
                    "Simple, rapide et efficace. J'économise sur mes impôts sans même avoir à quitter mon canapé !",
                profilePic: "assets/images/user3.webp",
                expertType: "Optimisation IA",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget: Carte de témoignage
  Widget _buildTestimonialCard({
    required String name,
    required String amount,
    required String testimonial,
    required String profilePic,
    required String expertType,
  }) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(profilePic), radius: 24),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "- $amount",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '"$testimonial"',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
          ),
          Spacer(),
          Divider(),
          Row(
            children: [
              Icon(Icons.verified, size: 16, color: Color(0xFF0F1C3F)),
              SizedBox(width: 6),
              Text(
                expertType,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget: Section des experts
  Widget _buildExpertsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Des experts à votre service',
            header: true, // Indique que c'est un en-tête
            child: Text(
              'Des experts à votre service',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B262C),
              ),
              textAlign: TextAlign.center,
              semanticsLabel:
                  'h3: Des experts à votre service', // Alternative pour indiquer le niveau h3
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildExpertIcon(
                icon: Icons.account_balance,
                label: "Notaires",
                count: 85,
              ),
              _buildExpertIcon(
                icon: Icons.person_outline,
                label: "CGP",
                count: 123,
              ),
              _buildExpertIcon(
                icon: Icons.business_center,
                label: "Experts-Comptables",
                count: 67,
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            "Notre réseau de professionnels qualifiés peut vous accompagner pour une optimisation fiscale personnalisée.",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // Ouvrir une page d'information sur les experts
              // ou afficher un modal
            },
            child: Text(
              "En savoir plus sur notre réseau",
              style: TextStyle(
                color: Color(0xFF0F1C3F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Icône d'expert avec compteur
  Widget _buildExpertIcon({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF0F1C3F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF0F1C3F), size: 28),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          "$count+",
          style: TextStyle(
            color: Color(0xFF3282B8),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget: Section des avantages
  Widget _buildBenefitsSection() {
    return Column(
      children: [
        Semantics(
          label: 'Pourquoi utiliser Le Fiscaliste ?',
          header: true, // Indique que c'est un en-tête
          child: Text(
            'Pourquoi utiliser Le Fiscaliste ?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B262C),
            ),
            textAlign: TextAlign.center,
            semanticsLabel:
                'h3: Pourquoi utiliser Le Fiscaliste ?', // Alternative pour indiquer le niveau h3
          ),
        ),
        SizedBox(height: 20),
        _buildBenefitItem(
          icon: Icons.bolt,
          title: "Rapide et efficace",
          description:
              "3 minutes suffisent pour obtenir une analyse personnalisée",
        ),
        SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.verified_user,
          title: "Expertise fiscale",
          description: "IA entraînée avec des milliers de cas fiscaux réels",
        ),
        SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.auto_awesome,
          title: "Conseils personnalisés",
          description:
              "Exploitez toutes les niches fiscales adaptées à votre situation",
        ),
        SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.people,
          title: "Experts disponibles",
          description: "Mise en relation avec des professionnels qualifiés",
        ),
      ],
    );
  }

  // Widget: Item d'avantage
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF0F1C3F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFF0F1C3F), size: 24),
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
    );
  }

  // Méthode: Partager l'application
  void _shareApp() {
    HapticFeedback.lightImpact();

    final String shareText =
        "J'ai découvert combien je pouvais économiser sur mes impôts avec Le Fiscaliste ! "
        "Fais le test gratuit ici: https://lefiscaliste.fr";

    Share.share(shareText, subject: 'Économise sur tes impôts !');

    // Analytics: Suivi du partage
    // analyticsService.logShare('home_page');
  }
}
