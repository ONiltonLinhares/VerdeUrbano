import 'enums.dart';

/// Tabela local `registros_diario` (SQLite). RNF04: nunca vai para o Firestore.
class RegistroDiario {
  RegistroDiario({
    this.id,
    this.areaId,
    required this.areaNome,
    required this.humor,
    required this.atividades,
    this.anotacao,
    required this.dataHora,
  });

  final int? id; // null até ser gravado (AUTOINCREMENT)
  final String? areaId;
  final String areaNome;
  final Humor humor;
  final List<AtividadeRealizada> atividades;
  final String? anotacao;
  final DateTime dataHora;

  factory RegistroDiario.fromSqlite(Map<String, Object?> row) {
    final atividadesTexto = row['atividades'] as String? ?? '';
    return RegistroDiario(
      id: row['id'] as int?,
      areaId: row['area_id'] as String?,
      areaNome: row['area_nome'] as String? ?? '',
      humor: enumPorNome(Humor.values, row['humor'], Humor.neutro),
      atividades: [
        for (final a in atividadesTexto.split(','))
          if (AtividadeRealizada.values.any((e) => e.name == a))
            AtividadeRealizada.values.byName(a),
      ],
      anotacao: row['anotacao'] as String?,
      dataHora: DateTime.tryParse(row['data_hora'] as String? ?? '') ??
          DateTime(1970),
    );
  }

  Map<String, Object?> toSqlite() => {
        if (id != null) 'id': id,
        'area_id': areaId,
        'area_nome': areaNome,
        'humor': humor.name,
        'atividades': atividades.map((a) => a.name).join(','),
        'anotacao': anotacao,
        'data_hora': dataHora.toIso8601String(),
      };
}
