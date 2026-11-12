import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Subcoleção `areas_verdes/{areaId}/fotos/{fotoId}` — CRUD 4 da Unidade I
/// (fotos enviadas pela comunidade).
///
/// A imagem fica **dentro do documento**, em base64, e não no Firebase
/// Storage: o Storage exige o plano pago (Blaze) e a stack da disciplina é
/// Auth + banco de dados. Limite: o documento do Firestore tem no máximo
/// 1 MiB, então o app comprime a foto para até [tamanhoMaximoBytes] antes
/// de enviar. Decisão explicada em docs/modelagem-dados.md, seção 1.
class Foto {
  Foto({
    required this.id,
    required this.areaId,
    required this.autorId,
    required this.autorNome,
    required this.imagemBase64,
    this.legenda = '',
    required this.criadoEm,
    required this.atualizadoEm,
  });

  /// 700 KB de imagem → ~930 KB em base64, abaixo do limite de 1 MiB.
  static const tamanhoMaximoBytes = 700 * 1024;

  final String id;
  final String areaId;
  final String autorId;
  final String autorNome;
  final String imagemBase64;
  final String legenda;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Uint8List get bytes => base64Decode(imagemBase64);

  bool podeEditar(String? uid) => uid != null && uid == autorId;

  factory Foto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Foto(
      id: doc.id,
      areaId: doc.reference.parent.parent?.id ?? '',
      autorId: d['autorId'] as String? ?? '',
      autorNome: d['autorNome'] as String? ?? 'Usuário',
      imagemBase64: d['imagemBase64'] as String? ?? '',
      legenda: d['legenda'] as String? ?? '',
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
      atualizadoEm: (d['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'autorId': autorId,
        'autorNome': autorNome,
        'imagemBase64': imagemBase64,
        'legenda': legenda,
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}
