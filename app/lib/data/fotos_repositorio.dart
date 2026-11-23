import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/erros.dart';
import '../models/foto.dart';

/// CRUD de fotos da comunidade (CRUD 4). Subcoleção `areas_verdes/{id}/fotos`.
/// A imagem vai em base64 dentro do documento (ver Foto e modelagem-dados.md).
class FotosRepositorio {
  FotosRepositorio._();
  static final instancia = FotosRepositorio._();

  CollectionReference<Map<String, dynamic>> _col(String areaId) =>
      FirebaseFirestore.instance
          .collection('areas_verdes')
          .doc(areaId)
          .collection('fotos');

  Stream<List<Foto>> observar(String areaId) => _col(areaId)
      .orderBy('criadoEm', descending: true)
      .limit(30)
      .snapshots()
      .map((s) => s.docs.map(Foto.fromFirestore).toList());

  /// Regra: imagem de até [Foto.tamanhoMaximoBytes] e legenda de até 200.
  static void validar(Uint8List bytes, String legenda) {
    if (bytes.isEmpty) throw const ErroApp('Escolha uma foto.');
    if (bytes.length > Foto.tamanhoMaximoBytes) {
      throw const ErroApp(
          'A foto ficou grande demais mesmo comprimida. Tente outra imagem.');
    }
    if (legenda.length > 200) {
      throw const ErroApp('A legenda pode ter no máximo 200 caracteres.');
    }
  }

  Future<void> enviar({
    required String areaId,
    required String autorId,
    required String autorNome,
    required Uint8List bytes,
    required String legenda,
  }) async {
    validar(bytes, legenda);
    final agora = DateTime.now();
    final foto = Foto(
      id: '',
      areaId: areaId,
      autorId: autorId,
      autorNome: autorNome,
      imagemBase64: base64Encode(bytes),
      legenda: legenda.trim(),
      criadoEm: agora,
      atualizadoEm: agora,
    );
    try {
      await comLimiteDeTempo(_col(areaId).add(foto.toFirestore()),
          limite: const Duration(seconds: 40));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Só o autor edita (a regra impede trocar o autor).
  Future<void> atualizarLegenda(Foto foto, String legenda) async {
    if (legenda.length > 200) {
      throw const ErroApp('A legenda pode ter no máximo 200 caracteres.');
    }
    try {
      await comLimiteDeTempo(_col(foto.areaId).doc(foto.id).update({
        'legenda': legenda.trim(),
        'atualizadoEm': Timestamp.fromDate(DateTime.now()),
      }));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  Future<void> excluir(Foto foto) async {
    try {
      await comLimiteDeTempo(_col(foto.areaId).doc(foto.id).delete());
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }
}
