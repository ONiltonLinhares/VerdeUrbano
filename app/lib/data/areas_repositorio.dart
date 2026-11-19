import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/erros.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import 'avaliacoes_repositorio.dart';

/// CRUD de áreas verdes (CRUD 2). Coleção `areas_verdes`.
///
/// As consultas sempre filtram o que a regra de leitura permite
/// (`status == publicada`, ou `criadoPor == uid`, ou admin): o Firestore
/// recusa consultas que poderiam devolver documentos proibidos.
class AreasRepositorio {
  AreasRepositorio._();
  static final instancia = AreasRepositorio._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('areas_verdes');

  /// Lista pública (RNF03: sem login). Com o cache do Firestore, a última
  /// lista carregada continua aparecendo sem internet.
  Stream<List<AreaVerde>> observarPublicadas() => _col
      .where('status', isEqualTo: StatusArea.publicada.name)
      .snapshots()
      .map((s) => s.docs.map(AreaVerde.fromFirestore).toList()
        ..sort((a, b) => a.nome.compareTo(b.nome)));

  Stream<AreaVerde?> observar(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? AreaVerde.fromFirestore(d) : null);

  /// Admin: sugestões de moradores aguardando aprovação.
  Stream<List<AreaVerde>> observarPendentes() => _col
      .where('status', isEqualTo: StatusArea.pendente.name)
      .snapshots()
      .map((s) => s.docs.map(AreaVerde.fromFirestore).toList());

  /// Morador: acompanha as próprias sugestões.
  Stream<List<AreaVerde>> observarMinhasSugestoes(String uid) => _col
      .where('criadoPor', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(AreaVerde.fromFirestore).toList());

  /// Admin cadastra publicada; morador sugere (entra pendente, resumo zerado).
  Future<String> criar(AreaVerde area) async {
    try {
      final ref = await comLimiteDeTempo(_col.add({
        ...area.toFirestore(),
        'resumo': const ResumoAvaliacoes().toMap(),
      }));
      return ref.id;
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Admin: edita os dados. O resumo de avaliações não é reenviado, para não
  /// sobrescrever avaliações feitas enquanto o formulário estava aberto.
  Future<void> atualizar(AreaVerde area) async {
    try {
      final dados = area.toFirestore()..remove('resumo');
      await comLimiteDeTempo(_col.doc(area.id).update(dados));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Admin: publicar sugestão, desativar (exclusão lógica) ou reativar.
  Future<void> alterarStatus(String id, StatusArea status) async {
    try {
      await comLimiteDeTempo(_col.doc(id).update({
        'status': status.name,
        'atualizadoEm': Timestamp.fromDate(DateTime.now()),
      }));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Admin: exclusão definitiva (local fechado ou duplicado).
  /// O Firestore não apaga subcoleções sozinho. Cada avaliação é removida
  /// pela mesma transação do autor (a regra exige o resumo caindo junto);
  /// fotos e eventos são apagados em lote; por último, a área.
  Future<void> excluirDefinitivamente(String id) async {
    try {
      final area = _col.doc(id);
      final avaliacoes = await area.collection('avaliacoes').get();
      for (final a in avaliacoes.docs) {
        await AvaliacoesRepositorio.instancia.excluir(id, a.id);
      }
      final lote = FirebaseFirestore.instance.batch();
      for (final sub in ['fotos', 'eventos']) {
        final docs = await area.collection(sub).get();
        for (final d in docs.docs) {
          lote.delete(d.reference);
        }
      }
      lote.delete(area);
      await comLimiteDeTempo(lote.commit());
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }
}
