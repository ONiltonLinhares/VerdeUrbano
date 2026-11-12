import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Coleção `usuarios/{uid}` — o id do documento é o uid do Firebase Auth.
class Usuario {
  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoUrl,
    this.preferencias = const [],
    this.papel = PapelUsuario.usuario,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final String id;
  final String nome;
  final String email;
  final String? fotoUrl;
  final List<Atividade> preferencias;
  final PapelUsuario papel; // nunca alterado pelo app (regra do Firestore)
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  bool get isAdmin => papel == PapelUsuario.admin;

  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Usuario(
      id: doc.id,
      nome: d['nome'] as String? ?? '',
      email: d['email'] as String? ?? '',
      fotoUrl: d['fotoUrl'] as String?,
      preferencias: [
        for (final p in (d['preferencias'] as List? ?? const []))
          if (Atividade.values.any((e) => e.name == p))
            Atividade.values.byName(p as String),
      ],
      papel: enumPorNome(PapelUsuario.values, d['papel'], PapelUsuario.usuario),
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
      atualizadoEm: (d['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'email': email,
        'fotoUrl': fotoUrl,
        'preferencias': preferencias.map((p) => p.name).toList(),
        'papel': papel.name,
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}
