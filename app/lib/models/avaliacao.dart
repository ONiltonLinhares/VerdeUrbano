import 'package:cloud_firestore/cloud_firestore.dart';

/// Subcoleção `areas_verdes/{areaId}/avaliacoes/{uid}`.
/// O id do documento é o uid do autor: uma avaliação por pessoa por local.
class Avaliacao {
  Avaliacao({
    required this.id,
    required this.areaId,
    required this.autorId,
    required this.autorNome,
    required this.nota,
    required this.notaLimpeza,
    required this.notaConservacao,
    required this.notaAcessibilidade,
    required this.comentario,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final String id;
  final String areaId;
  final String autorId;
  final String autorNome;
  final int nota; // 1 a 5
  final int notaLimpeza;
  final int notaConservacao;
  final int notaAcessibilidade;
  final String comentario;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  bool podeEditar(String? uid) => uid != null && uid == autorId;

  factory Avaliacao.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Avaliacao(
      id: doc.id,
      // areaId vem do caminho: areas_verdes/{areaId}/avaliacoes/{id}
      areaId: doc.reference.parent.parent?.id ?? '',
      autorId: d['autorId'] as String? ?? doc.id,
      autorNome: d['autorNome'] as String? ?? 'Usuário',
      nota: (d['nota'] as num?)?.toInt() ?? 0,
      notaLimpeza: (d['notaLimpeza'] as num?)?.toInt() ?? 0,
      notaConservacao: (d['notaConservacao'] as num?)?.toInt() ?? 0,
      notaAcessibilidade: (d['notaAcessibilidade'] as num?)?.toInt() ?? 0,
      comentario: d['comentario'] as String? ?? '',
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
      atualizadoEm: (d['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'autorId': autorId,
        'autorNome': autorNome,
        'nota': nota,
        'notaLimpeza': notaLimpeza,
        'notaConservacao': notaConservacao,
        'notaAcessibilidade': notaAcessibilidade,
        'comentario': comentario,
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}
