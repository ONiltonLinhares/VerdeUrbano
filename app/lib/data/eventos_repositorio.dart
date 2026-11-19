import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/erros.dart';
import '../models/enums.dart';
import '../models/evento.dart';

/// CRUD de eventos e mutirões (CRUD 5). Subcoleção `areas_verdes/{id}/eventos`.
class EventosRepositorio {
  EventosRepositorio._();
  static final instancia = EventosRepositorio._();

  CollectionReference<Map<String, dynamic>> _col(String areaId) =>
      FirebaseFirestore.instance
          .collection('areas_verdes')
          .doc(areaId)
          .collection('eventos');

  /// Próximos eventos (os que ainda não terminaram), em ordem de data.
  Stream<List<Evento>> observarProximos(String areaId) => _col(areaId)
      .where('fim', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .snapshots()
      .map((s) => s.docs.map(Evento.fromFirestore).toList()
        ..sort((a, b) => a.inicio.compareTo(b.inicio)));

  /// Regras de negócio (as mesmas do firestore.rules).
  static void validar(Evento e, {bool novo = false}) {
    if (e.titulo.trim().isEmpty) throw const ErroApp('Dê um título ao evento.');
    if (e.titulo.length > 80) throw const ErroApp('Título com no máximo 80 caracteres.');
    if (e.descricao.length > 1000) {
      throw const ErroApp('Descrição com no máximo 1000 caracteres.');
    }
    if (!e.periodoValido) {
      throw const ErroApp('O evento precisa terminar depois de começar.');
    }
    if (novo && !e.inicio.isAfter(DateTime.now())) {
      throw const ErroApp('Não é possível criar evento no passado.');
    }
  }

  Future<void> criar(Evento e) async {
    validar(e, novo: true);
    try {
      await comLimiteDeTempo(_col(e.areaId).add(e.toFirestore()));
    } catch (erro) {
      throw ErroApp(mensagemDeErro(erro));
    }
  }

  Future<void> atualizar(Evento e) async {
    validar(e);
    try {
      await comLimiteDeTempo(_col(e.areaId).doc(e.id).update(e.toFirestore()));
    } catch (erro) {
      throw ErroApp(mensagemDeErro(erro));
    }
  }

  Future<void> cancelar(Evento e) async {
    try {
      await comLimiteDeTempo(_col(e.areaId)
          .doc(e.id)
          .update({'status': StatusEvento.cancelado.name}));
    } catch (erro) {
      throw ErroApp(mensagemDeErro(erro));
    }
  }

  Future<void> excluir(Evento e) async {
    try {
      await comLimiteDeTempo(_col(e.areaId).doc(e.id).delete());
    } catch (erro) {
      throw ErroApp(mensagemDeErro(erro));
    }
  }
}
