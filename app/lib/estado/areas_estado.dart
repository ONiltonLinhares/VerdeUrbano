import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/erros.dart';
import '../data/areas_repositorio.dart';
import '../data/offline_repositorio.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import 'localizacao_estado.dart';

/// Lista de áreas verdes + busca e filtros, compartilhada entre Início,
/// Mapa e Salvos. Se o Firestore falhar e não houver cache, usa as cópias
/// offline (RF12).
class AreasEstado extends ChangeNotifier {
  AreasEstado._();
  static final instancia = AreasEstado._();

  StreamSubscription<List<AreaVerde>>? _sub;
  List<AreaVerde> _areas = [];
  bool _carregando = true;
  String? _erro;
  bool _usandoOffline = false;

  List<AreaVerde> get areas => _areas;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get usandoOffline => _usandoOffline;

  // ---------- filtros (RF04, RF05, RF13 + acessibilidade e distância) ----------
  String _busca = '';
  final Set<Atividade> atividades = {};
  final Set<Recurso> estrutura = {};
  final Set<RecursoAcessibilidade> acessibilidade = {};
  double? distanciaMaxima; // metros

  String get busca => _busca;

  int get quantidadeFiltros =>
      atividades.length +
      estrutura.length +
      acessibilidade.length +
      (distanciaMaxima != null ? 1 : 0);

  void iniciar() {
    _sub?.cancel();
    _carregando = true;
    _erro = null;
    notifyListeners();
    _sub = AreasRepositorio.instancia.observarPublicadas().listen(
      (lista) {
        _areas = lista;
        _usandoOffline = false;
        _carregando = false;
        _erro = null;
        notifyListeners();
      },
      onError: (Object e) {
        final salvos =
            OfflineRepositorio.instancia.locais.map((l) => l.area).toList();
        _usandoOffline = salvos.isNotEmpty;
        if (salvos.isNotEmpty) _areas = salvos;
        _erro = salvos.isEmpty ? mensagemDeErro(e) : null;
        _carregando = false;
        notifyListeners();
      },
    );
  }

  /// Só para testes: carrega uma lista sem passar pelo Firestore.
  @visibleForTesting
  void definirAreasParaTeste(List<AreaVerde> areas) {
    _areas = areas;
    _carregando = false;
    _erro = null;
    notifyListeners();
  }

  AreaVerde? porId(String id) {
    for (final a in _areas) {
      if (a.id == id) return a;
    }
    return OfflineRepositorio.instancia.obter(id)?.area;
  }

  void definirBusca(String v) {
    _busca = v;
    notifyListeners();
  }

  void alternar<T>(Set<T> grupo, T valor) {
    if (!grupo.remove(valor)) grupo.add(valor);
    notifyListeners();
  }

  void definirDistancia(double? metros) {
    distanciaMaxima = metros;
    notifyListeners();
  }

  void limparAtividades() {
    atividades.clear();
    notifyListeners();
  }

  void limparFiltros() {
    atividades.clear();
    estrutura.clear();
    acessibilidade.clear();
    distanciaMaxima = null;
    notifyListeners();
  }

  /// Aplica busca + filtros e ordena pela distância quando há GPS.
  List<AreaVerde> filtradas([LocalizacaoEstado? loc]) {
    final l = loc ?? LocalizacaoEstado.instancia;
    final resultado = _areas.where((a) {
      if (!a.correspondeBusca(_busca)) return false;
      if (!atividades.every(a.atividades.contains)) return false;
      if (!estrutura.every((r) => a.estrutura[r] == Disponibilidade.tem)) {
        return false;
      }
      if (!acessibilidade
          .every((r) => a.acessibilidade[r] == Disponibilidade.tem)) {
        return false;
      }
      final max = distanciaMaxima;
      if (max != null) {
        final d = l.distanciaAte(a);
        if (d != null && d > max) return false;
      }
      return true;
    }).toList();

    if (l.temPosicao) {
      resultado.sort((a, b) => l.distanciaAte(a)!.compareTo(l.distanciaAte(b)!));
    }
    return resultado;
  }
}
