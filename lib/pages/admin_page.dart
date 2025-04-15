import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:le_fiscaliste_04/services/database_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminLeadsPage extends StatefulWidget {
  const AdminLeadsPage({Key? key}) : super(key: key);

  @override
  _AdminLeadsPageState createState() => _AdminLeadsPageState();
}

class _AdminLeadsPageState extends State<AdminLeadsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _leads = [];
  List<Map<String, dynamic>> _filteredLeads = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Options de tri
  String _sortBy = 'date_creation';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final leads = await _databaseService.getAllLeads();
      setState(() {
        _leads = leads;
        _filteredLeads = List.from(leads);
        _sortLeads();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de chargement: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortLeads() {
    _filteredLeads.sort((a, b) {
      dynamic valueA = a[_sortBy];
      dynamic valueB = b[_sortBy];

      // Traitement spécial pour les dates
      if (_sortBy == 'date_creation') {
        try {
          valueA = DateTime.parse(valueA.toString());
          valueB = DateTime.parse(valueB.toString());
        } catch (e) {
          // Si le parsing échoue, utiliser les valeurs d'origine
        }
      }

      // Comparaison en fonction du type
      int comparison;
      if (valueA == null && valueB == null) {
        comparison = 0;
      } else if (valueA == null) {
        comparison = -1;
      } else if (valueB == null) {
        comparison = 1;
      } else if (valueA is DateTime && valueB is DateTime) {
        comparison = valueA.compareTo(valueB);
      } else if (valueA is num && valueB is num) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = valueA.toString().compareTo(valueB.toString());
      }

      // Inverser si tri descendant
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _searchLeads(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();

      if (_searchQuery.isEmpty) {
        _filteredLeads = List.from(_leads);
      } else {
        _filteredLeads =
            _leads.where((lead) {
              final nom = (lead['nom'] ?? '').toLowerCase();
              final prenom = (lead['prenom'] ?? '').toLowerCase();
              final email = (lead['email'] ?? '').toLowerCase();
              final telephone = (lead['telephone'] ?? '').toLowerCase();

              return nom.contains(_searchQuery) ||
                  prenom.contains(_searchQuery) ||
                  email.contains(_searchQuery) ||
                  telephone.contains(_searchQuery);
            }).toList();
      }

      _sortLeads();
    });
  }

  Future<void> _exportLeads() async {
    try {
      final data = jsonEncode(_leads);
      await Clipboard.setData(ClipboardData(text: data));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Données exportées dans le presse-papier (format JSON)',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'exportation: $e')),
      );
    }
  }

  Future<void> _confirmDelete(int leadId) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer ce lead ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ANNULER'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteLead(leadId);
                },
                child: Text('SUPPRIMER'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteLead(int leadId) async {
    try {
      await _databaseService.deleteLead(leadId);

      setState(() {
        _leads.removeWhere((lead) => lead['id'] == leadId);
        _filteredLeads.removeWhere((lead) => lead['id'] == leadId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lead supprimé avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Date inconnue';

    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  void _showLeadDetails(Map<String, dynamic> lead) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${lead['prenom'] ?? ''} ${lead['nom'] ?? ''}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _infoRow('Email', lead['email']),
                  _infoRow('Téléphone', lead['telephone']),
                  _infoRow('Date', _formatDate(lead['date_creation'])),
                  _infoRow(
                    'Consentement Marketing',
                    lead['consentement_marketing'] == true ? 'Oui' : 'Non',
                  ),

                  Divider(height: 30),
                  Text(
                    'Réponses au Quiz',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),

                  // Afficher les réponses au quiz
                  if (lead['quiz_responses'] != null)
                    ..._buildQuizResponsesList(lead['quiz_responses']),

                  Divider(height: 30),
                  Text(
                    'Conseil Généré',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),

                  Text(lead['conseil'] ?? 'Aucun conseil généré'),
                ],
              ),
            ),
            actions: [
              // Bouton pour copier les coordonnées
              TextButton.icon(
                icon: Icon(Icons.copy),
                label: Text('COPIER'),
                onPressed: () {
                  final contactInfo =
                      'Nom: ${lead['nom']}\n'
                      'Prénom: ${lead['prenom']}\n'
                      'Email: ${lead['email']}\n'
                      'Téléphone: ${lead['telephone']}';

                  Clipboard.setData(ClipboardData(text: contactInfo));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Coordonnées copiées')),
                  );
                },
              ),

              // Bouton pour supprimer
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete(lead['id']);
                },
              ),

              TextButton(
                child: Text('FERMER'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'Non renseigné')),
        ],
      ),
    );
  }

  List<Widget> _buildQuizResponsesList(dynamic responses) {
    final List<Widget> widgets = [];

    // Si responses est une chaîne JSON, le convertir en Map
    Map<String, dynamic> responsesMap;
    if (responses is String) {
      try {
        responsesMap = jsonDecode(responses);
      } catch (e) {
        return [Text('Format de réponses invalide')];
      }
    } else if (responses is Map) {
      responsesMap = Map<String, dynamic>.from(responses);
    } else {
      return [Text('Aucune réponse disponible')];
    }

    // Mapper les clés techniques vers des libellés lisibles
    final Map<String, String> keyLabels = {
      'situation': 'Situation familiale',
      'enfants': 'Nombre d\'enfants',
      'revenus': 'Tranche de revenus',
      'propriétaire': 'Propriétaire',
      'investissements_locatifs': 'Investissements locatifs',
      'placements': 'Placements financiers',
      'entrepreneur': 'Entrepreneur/Libéral',
      'defiscalisation': 'Investissements défiscalisants',
      'objectif': 'Objectif fiscal',
      'risque': 'Tolérance au risque',
    };

    // Créer un widget pour chaque réponse
    responsesMap.forEach((key, value) {
      widgets.add(_infoRow(keyLabels[key] ?? key, value?.toString()));
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Leads'),
        backgroundColor: Color(0xFF0F4C75),
        actions: [
          // Bouton d'exportation
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Exporter les leads',
            onPressed: _exportLeads,
          ),

          // Bouton de rafraîchissement
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: _loadLeads,
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec recherche et filtres
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un lead...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: _searchLeads,
                ),

                SizedBox(height: 10),

                // Options de tri
                Row(
                  children: [
                    Text('Trier par: '),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: [
                        DropdownMenuItem(
                          value: 'date_creation',
                          child: Text('Date'),
                        ),
                        DropdownMenuItem(value: 'nom', child: Text('Nom')),
                        DropdownMenuItem(
                          value: 'prenom',
                          child: Text('Prénom'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                            _sortLeads();
                          });
                        }
                      },
                    ),

                    SizedBox(width: 10),

                    // Bouton pour inverser l'ordre
                    IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                          _sortLeads();
                        });
                      },
                      tooltip:
                          _sortAscending
                              ? 'Ordre croissant'
                              : 'Ordre décroissant',
                    ),

                    Spacer(),

                    // Statistiques
                    Text(
                      '${_filteredLeads.length} lead(s)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des leads
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredLeads.isEmpty
                    ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'Aucun résultat pour "$_searchQuery"'
                            : 'Aucun lead trouvé',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredLeads.length,
                      itemBuilder: (context, index) {
                        final lead = _filteredLeads[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFF0F4C75),
                              child: Text(
                                (lead['prenom'] != null &&
                                        lead['prenom'].isNotEmpty)
                                    ? lead['prenom'][0].toUpperCase()
                                    : '?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              '${lead['prenom'] ?? ''} ${lead['nom'] ?? ''}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${lead['email'] ?? 'Email non renseigné'}',
                                ),
                                Text(
                                  'Tél: ${lead['telephone'] ?? 'Non renseigné'}',
                                ),
                                Text(
                                  'Le ${_formatDate(lead['date_creation'])}',
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Bouton copier
                                IconButton(
                                  icon: Icon(Icons.copy, size: 20),
                                  onPressed: () {
                                    final contactInfo =
                                        'Nom: ${lead['nom']}\n'
                                        'Prénom: ${lead['prenom']}\n'
                                        'Email: ${lead['email']}\n'
                                        'Téléphone: ${lead['telephone']}';

                                    Clipboard.setData(
                                      ClipboardData(text: contactInfo),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Coordonnées copiées'),
                                      ),
                                    );
                                  },
                                  tooltip: 'Copier les coordonnées',
                                ),

                                // Bouton supprimer
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(lead['id']),
                                  tooltip: 'Supprimer',
                                ),
                              ],
                            ),
                            onTap: () => _showLeadDetails(lead),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      // Indicateur de chargement
      bottomNavigationBar:
          _isLoading
              ? Container(height: 4, child: LinearProgressIndicator())
              : null,
      // FAB pour exporter
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportLeads,
        label: Text('Exporter'),
        icon: Icon(Icons.download),
        backgroundColor: Color(0xFF0F4C75),
      ),
    );
  }
}
