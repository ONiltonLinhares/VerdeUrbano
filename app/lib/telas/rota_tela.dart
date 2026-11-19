import 'package:material_ui/material_ui.dart';

import '../core/acoes_externas.dart';
import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../estado/localizacao_estado.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';

/// Tela Rota do protótipo (RF03): tempo estimado a pé, de bicicleta e de
/// ônibus, e "Iniciar navegação", que abre o app de mapas do aparelho
/// com o trajeto real.
class RotaTela extends StatefulWidget {
  const RotaTela({super.key, required this.area});
  final AreaVerde area;

  @override
  State<RotaTela> createState() => _RotaTelaState();
}

class _RotaTelaState extends State<RotaTela> {
  String _modo = 'a_pe';

  static const _modos = <String, (String, IconData)>{
    'a_pe': ('A pé', Icons.directions_walk),
    'bicicleta': ('Bicicleta', Icons.directions_bike),
    'onibus': ('Ônibus', Icons.directions_bus),
  };

  @override
  Widget build(BuildContext context) {
    final area = widget.area;
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: LocalizacaoEstado.instancia,
      builder: (context, _) {
        final dist = LocalizacaoEstado.instancia.distanciaAte(area);
        final min = dist == null ? null : minutosEstimados(dist, _modo);
        final chegada = min == null ? null : DateTime.now().add(Duration(minutes: min));
        final acessivel = area.isAcessivel;
        final iluminado =
            area.acessibilidade[RecursoAcessibilidade.iluminacao] == Disponibilidade.tem;

        return Scaffold(
          appBar: AppBar(title: const Text('Rota')),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            Text('Da sua localização até', style: tema.textTheme.bodyMedium),
            Text(area.nome, style: tema.textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(children: [
              for (final m in _modos.entries)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _CartaoModo(
                      rotulo: m.value.$1,
                      icone: m.value.$2,
                      minutos: dist == null ? null : minutosEstimados(dist, m.key),
                      selecionado: _modo == m.key,
                      aoTocar: () => setState(() => _modo = m.key),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 24),
            if (dist == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Cores.areia, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Ative a localização para ver o tempo estimado.'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: LocalizacaoEstado.instancia.atualizar,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar minha localização'),
                  ),
                ]),
              )
            else ...[
              Text('$min min', style: tema.textTheme.displaySmall),
              Text(
                '${formatarDistancia(dist)} · chega às '
                '${doisDigitos(chegada!.hour)}h${doisDigitos(chegada.minute)}',
                style: tema.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text('Estimativa. O trajeto exato é calculado pelo app de mapas.',
                  style: tema.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            if (acessivel || iluminado)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Cores.folhaClara, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.accessible, color: Cores.floresta),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text([
                      if (acessivel) 'Local com rampas e caminhos acessíveis',
                      if (iluminado) 'boa iluminação noturna',
                    ].join(' e ')),
                  ),
                ]),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final ok = await AcoesExternas.abrirRota(area, modo: _modo);
                if (!ok && context.mounted) {
                  avisar(context, 'Nenhum app de mapas disponível no aparelho.');
                }
              },
              icon: const Icon(Icons.navigation_outlined),
              label: const Text('Iniciar navegação'),
            ),
          ]),
        );
      },
    );
  }
}

class _CartaoModo extends StatelessWidget {
  const _CartaoModo({
    required this.rotulo,
    required this.icone,
    required this.minutos,
    required this.selecionado,
    required this.aoTocar,
  });

  final String rotulo;
  final IconData icone;
  final int? minutos;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selecionado,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: aoTocar,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selecionado ? Cores.folhaClara : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selecionado ? Cores.floresta : const Color(0xFFD6DCD8),
                width: selecionado ? 2 : 1,
              ),
            ),
            child: Column(children: [
              Icon(icone, color: Cores.floresta),
              const SizedBox(height: 4),
              Text(rotulo, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(minutos == null ? '—' : '$minutos min'),
            ]),
          ),
        ),
      );
}
