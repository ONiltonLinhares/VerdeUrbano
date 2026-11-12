import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Subcoleção `areas_verdes/{areaId}/eventos/{eventoId}` — CRUD 5 da
/// Unidade I (eventos e mutirões: ioga, grupo de corrida, plantio, feira).
class Evento {
  Evento({
    required this.id,
    required this.areaId,
    required this.titulo,
    this.descricao = '',
    required this.tipo,
    required this.inicio,
    required this.fim,
    required this.organizadorId,
    required this.organizadorNome,
    this.status = StatusEvento.agendado,
  });

  final String id;
  final String areaId;
  final String titulo;
  final String descricao;
  final TipoEvento tipo;
  final DateTime inicio;
  final DateTime fim;
  final String organizadorId;
  final String organizadorNome;
  final StatusEvento status;

  bool get periodoValido => fim.isAfter(inicio);

  bool jaAconteceu(DateTime agora) => fim.isBefore(agora);

  bool podeEditar(String? uid) => uid != null && uid == organizadorId;

  factory Evento.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Evento(
      id: doc.id,
      areaId: doc.reference.parent.parent?.id ?? '',
      titulo: d['titulo'] as String? ?? '',
      descricao: d['descricao'] as String? ?? '',
      tipo: enumPorNome(TipoEvento.values, d['tipo'], TipoEvento.outro),
      inicio: (d['inicio'] as Timestamp?)?.toDate() ?? DateTime(1970),
      fim: (d['fim'] as Timestamp?)?.toDate() ?? DateTime(1970),
      organizadorId: d['organizadorId'] as String? ?? '',
      organizadorNome: d['organizadorNome'] as String? ?? 'Usuário',
      status: enumPorNome(StatusEvento.values, d['status'], StatusEvento.agendado),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'titulo': titulo,
        'descricao': descricao,
        'tipo': tipo.name,
        'inicio': Timestamp.fromDate(inicio),
        'fim': Timestamp.fromDate(fim),
        'organizadorId': organizadorId,
        'organizadorNome': organizadorNome,
        'status': status.name,
      };
}
