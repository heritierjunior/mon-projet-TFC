import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEventEntity {
  final String id;
  final String titreEvent;
  final String descriptionEvent;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String anneeAcad;

  CalendarEventEntity({
    required this.id,
    required this.titreEvent,
    required this.descriptionEvent,
    required this.dateDebut,
    required this.dateFin,
    this.anneeAcad = '2025-2026',
  });

  factory CalendarEventEntity.fromMap(Map<String, dynamic> map, String id) {
    return CalendarEventEntity(
      id: id,
      titreEvent: map['titre_event'] ?? '',
      descriptionEvent: map['description_event'] ?? '',
      dateDebut: (map['date_debut'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateFin: (map['date_fin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      anneeAcad: map['annee_acad'] ?? '2025-2026',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titre_event': titreEvent,
      'description_event': descriptionEvent,
      'date_debut': Timestamp.fromDate(dateDebut),
      'date_fin': Timestamp.fromDate(dateFin),
      'annee_acad': anneeAcad,
    };
  }
}
