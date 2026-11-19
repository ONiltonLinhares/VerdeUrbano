import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/erros.dart';
import '../models/area_verde.dart';
import '../models/avaliacao.dart';

/// CRUD de avaliações (CRUD 3, RF09).
///
/// Avaliação e resumo da área são gravados na MESMA transação, com as contas
/// de `ResumoAvaliacoes` (adicionar / substituir / remover). O firestore.rules
/// confere essa conta: se não bater, o banco recusa.
class AvaliacoesRepositorio {
  AvaliacoesRepositorio._();
  static final instancia = AvaliacoesRepositorio._();

  DocumentReference<Map<String, dynamic>> _area(String areaId) =>
      FirebaseFirestore.instance.collection('areas_verdes').doc(areaId);

  CollectionReference<Map<String, dynamic>> _col(String areaId) =>
      _area(areaId).collection('avaliacoes');

  Stream<List<Avaliacao>> observar(String areaId) => _col(areaId)
      .orderBy('criadoEm', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Avaliacao.fromFirestore).toList());

  Future<Avaliacao?> minha(String areaId, String uid) async {
    try {
      final d = await comLimiteDeTempo(_col(areaId).doc(uid).get());
      return d.exists ? Avaliacao.fromFirestore(d) : null;
    } catch (_) {
      return null; // sem rede: o formulário abre vazio; salvar mostrará o erro
    }
  }

  /// Cria ou edita a avaliação do usuário (id = uid → 1 por pessoa por local).
  Future<void> salvar(Avaliacao nova) async {
    validar(nova);
    try {
      await comLimiteDeTempo(
        FirebaseFirestore.instance.runTransaction((tx) async {
          final areaRef = _area(nova.areaId);
          final avalRef = _col(nova.areaId).doc(nova.autorId);
          final areaDoc = await tx.get(areaRef);
          final avalDoc = await tx.get(avalRef);
          if (!areaDoc.exists) throw const ErroApp('Este local não existe mais.');

          final resumo = ResumoAvaliacoes.fromMap(
              (areaDoc.data()?['resumo'] as Map?)?.cast<String, dynamic>());

          if (!avalDoc.exists) {
            tx.set(avalRef, nova.toFirestore());
            tx.update(areaRef, {'resumo': resumo.adicionar(nova).toMap()});
            return;
          }

          final antiga = Avaliacao.fromFirestore(avalDoc);
          // A regra exige que criadoEm não mude na edição.
          final editada = Avaliacao(
            id: antiga.id,
            areaId: nova.areaId,
            autorId: nova.autorId,
            autorNome: nova.autorNome,
            nota: nova.nota,
            notaLimpeza: nova.notaLimpeza,
            notaConservacao: nova.notaConservacao,
            notaAcessibilidade: nova.notaAcessibilidade,
            comentario: nova.comentario,
            criadoEm: antiga.criadoEm,
            atualizadoEm: DateTime.now(),
          );
          // update (e não set) sem o campo criadoEm: o valor original fica
          // intacto no banco, como a regra exige.
          tx.update(avalRef, editada.toFirestore()..remove('criadoEm'));
          if (_notasMudaram(antiga, editada)) {
            tx.update(areaRef,
                {'resumo': resumo.substituir(antiga, editada).toMap()});
          }
        }),
      );
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Autor apaga a própria; admin modera. O resumo cai junto (total − 1).
  Future<void> excluir(String areaId, String autorId) async {
    try {
      await comLimiteDeTempo(
        FirebaseFirestore.instance.runTransaction((tx) async {
          final areaRef = _area(areaId);
          final avalRef = _col(areaId).doc(autorId);
          final areaDoc = await tx.get(areaRef);
          final avalDoc = await tx.get(avalRef);
          if (!avalDoc.exists || !areaDoc.exists) return;
          final resumo = ResumoAvaliacoes.fromMap(
              (areaDoc.data()?['resumo'] as Map?)?.cast<String, dynamic>());
          tx.delete(avalRef);
          tx.update(areaRef, {
            'resumo': resumo.remover(Avaliacao.fromFirestore(avalDoc)).toMap()
          });
        }),
      );
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  static bool _notasMudaram(Avaliacao a, Avaliacao b) =>
      a.nota != b.nota ||
      a.notaLimpeza != b.notaLimpeza ||
      a.notaConservacao != b.notaConservacao ||
      a.notaAcessibilidade != b.notaAcessibilidade;

  /// Regras de negócio da avaliação (iguais às do firestore.rules).
  static void validar(Avaliacao a) {
    bool fora(int n) => n < 1 || n > 5;
    if (fora(a.nota) ||
        fora(a.notaLimpeza) ||
        fora(a.notaConservacao) ||
        fora(a.notaAcessibilidade)) {
      throw const ErroApp('Dê uma nota de 1 a 5 em todos os critérios.');
    }
    if (a.comentario.length > 500) {
      throw const ErroApp('O comentário pode ter no máximo 500 caracteres.');
    }
    if (a.autorNome.isEmpty || a.autorNome.length > 60) {
      throw const ErroApp('Atualize seu nome no perfil antes de avaliar.');
    }
  }
}
