import 'package:flutter/material.dart';
import 'package:le_fiscaliste_04/pages/result_page.dart';
import 'package:le_fiscaliste_04/services/database_service.dart';

class LeadFormPage extends StatefulWidget {
  final String advice;
  final Map<String, String> quizResponses;

  const LeadFormPage({
    Key? key,
    required this.advice,
    required this.quizResponses,
  }) : super(key: key);

  @override
  _LeadFormPageState createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _consentMarketing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer l'objet lead avec toutes les données
        final leadData = {
          'nom': _nameController.text,
          'prenom': _firstNameController.text,
          'email': _emailController.text,
          'telephone': _phoneController.text,
          'consentement_marketing': _consentMarketing,
          'date_creation': DateTime.now().toIso8601String(),
          'quiz_responses': widget.quizResponses,
          'conseil': widget.advice,
        };

        // Enregistrer dans la base de données
        await DatabaseService().saveLead(leadData);

        // Naviguer vers la page de résultats
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultPage(
                    advice: widget.advice,
                    leadInfo: {
                      'nom': _nameController.text,
                      'prenom': _firstNameController.text,
                      'email': _emailController.text,
                    },
                  ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obtenez vos résultats'),
        backgroundColor: Color(0xFF0F4C75),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Plus qu\'une étape avant vos résultats !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C75),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Complétez ces informations pour recevoir votre analyse personnalisée.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Prénom
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Nom
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Téléphone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Case à cocher de consentement
                CheckboxListTile(
                  title: Text(
                    'J\'accepte d\'être contacté par des experts fiscaux partenaires.',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _consentMarketing,
                  onChanged: (bool? value) {
                    setState(() {
                      _consentMarketing = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 30),

                // Bouton de soumission
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'VOIR MES RÉSULTATS',
                            style: TextStyle(fontSize: 18),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0F4C75),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Notice légale
                Text(
                  'Vos données sont protégées conformément à notre politique de confidentialité et au RGPD.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
