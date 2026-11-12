import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Subcoleção `usuarios/{uid}/favoritos/{areaId}`.
/// O id do documento é o id da área: não existe favorito duplicado.
/// Nome, tipo e foto são copiados da área para a aba "Salvos" listar
/// sem precisar ler cada área de novo.
class Favorito {
  Favorito({
    required this.areaId,
    required this.nome,
    required this.tipo,
    this.fotoCapa,
    required this.adicionadoEm,
  });

  final String areaId;
  final String nome;
  final TipoArea tipo;
  final String? fotoCapa;
  final DateTime adicionadoEm;

  factory Favorito.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Favorito(
      areaId: doc.id,
      nome: d['nome'] as String? ?? '',
      tipo: enumPorNome(TipoArea.values, d['tipo'], TipoArea.parque),
      fotoCapa: d['fotoCapa'] as String?,
      adicionadoEm: (d['adicionadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'tipo': tipo.name,
        'fotoCapa': fotoCapa,
        'adicionadoEm': Timestamp.fromDate(adicionadoEm),
      };
}
