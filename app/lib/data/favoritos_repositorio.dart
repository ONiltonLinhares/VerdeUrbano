import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/erros.dart';
import '../models/favorito.dart';

/// CRUD de favoritos (CRUD 6 — RF14, RF15, RF16).
/// Subcoleção `usuarios/{uid}/favoritos/{areaId}`.
class FavoritosRepositorio {
  FavoritosRepositorio._();
  static final instancia = FavoritosRepositorio._();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('favoritos');

  Stream<List<Favorito>> observar(String uid) => _col(uid)
      .snapshots()
      .map((s) => s.docs.map(Favorito.fromFirestore).toList()
        ..sort((a, b) => b.adicionadoEm.compareTo(a.adicionadoEm)));

  /// A escrita não é aguardada de propósito: o Firestore aplica a mudança no
  /// cache local na hora (a tela atualiza mesmo sem internet) e sincroniza
  /// quando a conexão voltar. Se o servidor recusar, [aoFalhar] é chamado.
  void adicionar(String uid, String areaId,
      {void Function(String mensagem)? aoFalhar}) {
    _col(uid)
        .doc(areaId)
        .set(Favorito(areaId: areaId, adicionadoEm: DateTime.now()).toFirestore())
        .catchError((Object e) {
      aoFalhar?.call(mensagemDeErro(e));
    });
  }

  void remover(String uid, String areaId,
      {void Function(String mensagem)? aoFalhar}) {
    _col(uid)
        .doc(areaId)
        .delete()
        .catchError((Object e) {
      aoFalhar?.call(mensagemDeErro(e));
    });
  }
}
