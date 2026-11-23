import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/erros.dart';
import '../models/enums.dart';
import '../models/sinalizacao.dart';

/// Sinalização de informação incorreta (RF10) e moderação pelo admin.
class SinalizacoesRepositorio {
  SinalizacoesRepositorio._();
  static final instancia = SinalizacoesRepositorio._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('sinalizacoes');

  Future<void> enviar({
    required String areaId,
    required String autorId,
    required String descricao,
  }) async {
    final texto = descricao.trim();
    if (texto.length < 5) {
      throw const ErroApp('Descreva o problema (mínimo 5 caracteres).');
    }
    if (texto.length > 500) throw const ErroApp('Máximo de 500 caracteres.');
    try {
      await comLimiteDeTempo(_col.add(Sinalizacao(
        id: '',
        areaId: areaId,
        autorId: autorId,
        descricao: texto,
        criadoEm: DateTime.now(),
      ).toFirestore()));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Admin: fila de moderação.
  Stream<List<Sinalizacao>> observarPendentes() => _col
      .where('status', isEqualTo: StatusSinalizacao.pendente.name)
      .snapshots()
      .map((s) => s.docs.map(Sinalizacao.fromFirestore).toList()
        ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm)));

  Future<void> alterarStatus(String id, StatusSinalizacao status) async {
    try {
      await comLimiteDeTempo(_col.doc(id).update({'status': status.name}));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }
}
