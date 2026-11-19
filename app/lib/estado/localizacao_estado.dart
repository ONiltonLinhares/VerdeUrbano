import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/area_verde.dart';

enum StatusLocalizacao { desconhecido, carregando, ok, negada, desligada, erro }

/// Localização do usuário para mostrar distâncias (RF02).
/// Só é usada com autorização e nunca é enviada ao servidor.
class LocalizacaoEstado extends ChangeNotifier {
  LocalizacaoEstado._();
  static final instancia = LocalizacaoEstado._();

  Position? _posicao;
  StatusLocalizacao _status = StatusLocalizacao.desconhecido;

  Position? get posicao => _posicao;
  StatusLocalizacao get status => _status;
  bool get temPosicao => _posicao != null;

  Future<void> atualizar() async {
    _status = StatusLocalizacao.carregando;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _status = StatusLocalizacao.desligada;
        notifyListeners();
        return;
      }
      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        _status = StatusLocalizacao.negada;
        notifyListeners();
        return;
      }
      _posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _status = StatusLocalizacao.ok;
    } catch (_) {
      // Sem sinal de GPS agora: tenta a última posição conhecida.
      try {
        _posicao = await Geolocator.getLastKnownPosition();
      } catch (_) {}
      _status = _posicao != null ? StatusLocalizacao.ok : StatusLocalizacao.erro;
    }
    notifyListeners();
  }

  /// Distância em metros, ou null sem localização.
  double? distanciaAte(AreaVerde a) {
    final p = _posicao;
    return p == null ? null : a.distanciaAte(p.latitude, p.longitude);
  }
}
