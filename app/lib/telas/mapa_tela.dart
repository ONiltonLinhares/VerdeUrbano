import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../estado/areas_estado.dart';
import '../estado/localizacao_estado.dart';
import '../models/area_verde.dart';
import '../widgets/componentes.dart';
import 'filtros_folha.dart';
import 'rota_tela.dart';

/// Aba Mapa (RF01, RF02, RF03). OpenStreetMap: não exige login nem chave
/// de API (RNF03). Tocar no pino abre o card com "Rota" e "Ver detalhes".
class MapaTela extends StatefulWidget {
  const MapaTela({super.key});

  @override
  State<MapaTela> createState() => _MapaTelaState();
}

class _MapaTelaState extends State<MapaTela> {
  static const _centroPadrao = LatLng(-23.5870, -46.6580);
  final _mapa = MapController();
  AreaVerde? _selecionada;

  @override
  Widget build(BuildContext context) {
    final estado = AreasEstado.instancia;
    final loc = LocalizacaoEstado.instancia;

    return ListenableBuilder(
      listenable: Listenable.merge([estado, loc]),
      builder: (context, _) {
        final lista = estado.filtradas();
        final pos = loc.posicao;
        final centro = pos != null
            ? LatLng(pos.latitude, pos.longitude)
            : lista.isNotEmpty
                ? LatLng(lista.first.localizacao.latitude,
                    lista.first.localizacao.longitude)
                : _centroPadrao;

        return Stack(children: [
          FlutterMap(
            mapController: _mapa,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 13,
              onTap: (_, _) => setState(() => _selecionada = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.unit.verdeurbano.verde_urbano',
              ),
              MarkerLayer(markers: [
                if (pos != null)
                  Marker(
                    point: LatLng(pos.latitude, pos.longitude),
                    width: 22,
                    height: 22,
                    child: Semantics(
                      label: 'Você está aqui',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Cores.voce,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                for (final a in lista)
                  Marker(
                    point: LatLng(a.localizacao.latitude, a.localizacao.longitude),
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => setState(() => _selecionada = a),
                      child: Semantics(
                        button: true,
                        label: a.nome,
                        child: Icon(
                          Icons.location_on,
                          size: 48,
                          color: _selecionada?.id == a.id ? Cores.terra : Cores.floresta,
                        ),
                      ),
                    ),
                  ),
              ]),
              RichAttributionWidget(attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ]),
            ],
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(14),
                    child: TextField(
                      onChanged: estado.definirBusca,
                      decoration: InputDecoration(
                        hintText: 'Parque, bairro ou cidade',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Filtros',
                  onPressed: () => mostrarFiltros(context),
                  icon: const Icon(Icons.tune),
                ),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${lista.length} ${lista.length == 1 ? 'área verde' : 'áreas verdes'}'
                  '${estado.distanciaMaxima != null ? ' até ${formatarDistancia(estado.distanciaMaxima!)}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Cores.texto),
                ),
              ),
            ]),
          ),
          Positioned(
            right: 16,
            bottom: _selecionada == null ? 16 : 210,
            child: FloatingActionButton.small(
              heroTag: 'minha-localizacao',
              tooltip: 'Minha localização',
              onPressed: () async {
                await loc.atualizar();
                final p = loc.posicao;
                if (p != null) {
                  _mapa.move(LatLng(p.latitude, p.longitude), 14);
                } else if (context.mounted) {
                  avisar(context, 'Não foi possível obter sua localização.');
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selecionada != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _CardSelecionado(area: _selecionada!),
            ),
        ]);
      },
    );
  }
}

class _CardSelecionado extends StatelessWidget {
  const _CardSelecionado({required this.area});
  final AreaVerde area;

  @override
  Widget build(BuildContext context) {
    final dist = LocalizacaoEstado.instancia.distanciaAte(area);
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Sobretitulo(area),
            Text(area.nome, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Wrap(spacing: 10, children: [
              NotaArea(area.resumo, mostrarTotal: false),
              if (dist != null) Text(formatarDistancia(dist)),
              Text(situacaoHorario(area.horario, DateTime.now())),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => abrir(context, RotaTela(area: area)),
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('Rota'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => abrirLocal(context, area.id),
                  child: const Text('Ver detalhes'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
