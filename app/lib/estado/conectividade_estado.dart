import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Observa a conexão para avisar quando o app está offline.
class ConectividadeEstado extends ChangeNotifier {
  ConectividadeEstado._();
  static final instancia = ConectividadeEstado._();

  final _conn = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _online = true;

  bool get online => _online;

  Future<void> iniciar() async {
    try {
      _atualizar(await _conn.checkConnectivity());
    } catch (_) {}
    _sub ??= _conn.onConnectivityChanged.listen(_atualizar);
  }

  void _atualizar(List<ConnectivityResult> r) {
    final agora = r.any((x) => x != ConnectivityResult.none);
    if (agora != _online) {
      _online = agora;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
