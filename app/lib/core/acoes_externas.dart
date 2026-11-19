import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/area_verde.dart';

/// Ações que usam recursos nativos do aparelho.
abstract final class AcoesExternas {
  static Uri linkDoLocal(AreaVerde a) => Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${a.localizacao.latitude},${a.localizacao.longitude}');

  /// RF03 — abre o app de mapas já com a rota.
  /// [modo]: 'a_pe' | 'bicicleta' | 'onibus'.
  static Future<bool> abrirRota(AreaVerde a, {String modo = 'a_pe'}) async {
    const travel = {'a_pe': 'walking', 'bicicleta': 'bicycling', 'onibus': 'transit'};
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1'
        '&destination=${a.localizacao.latitude},${a.localizacao.longitude}'
        '&travelmode=${travel[modo] ?? 'walking'}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// RF17 — compartilha nome, endereço e link.
  static Future<void> compartilhar(AreaVerde a) => SharePlus.instance.share(
        ShareParams(
          text: '${a.nome}\n${a.endereco} · ${a.bairro}, ${a.cidade}\n'
              '${linkDoLocal(a)}\n\nEncontrei no VerdeUrbano 🌿',
          subject: a.nome,
        ),
      );
}
