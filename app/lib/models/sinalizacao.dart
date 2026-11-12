import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Coleção raiz `sinalizacoes/{id}` (RF10). Fica na raiz para o admin
/// moderar todas num lugar só.
class Sinalizacao {
  Sinalizacao({
    required this.id,
    required this.areaId,
    required this.autorId,
    required this.descricao,
    this.status = StatusSinalizacao.pendente,
    required this.criadoEm,
  });

  final String id;
  final String areaId;
  final String autorId;
  final String descricao;
  final StatusSinalizacao status;
  final DateTime criadoEm;

  factory Sinalizacao.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Sinalizacao(
      id: doc.id,
      areaId: d['areaId'] as String? ?? '',
      autorId: d['autorId'] as String? ?? '',
      descricao: d['descricao'] as String? ?? '',
      status: enumPorNome(
          StatusSinalizacao.values, d['status'], StatusSinalizacao.pendente),
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'areaId': areaId,
        'autorId': autorId,
        'descricao': descricao,
        'status': status.name,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
