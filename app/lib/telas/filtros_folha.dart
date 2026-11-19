import 'package:material_ui/material_ui.dart';

import '../estado/areas_estado.dart';
import '../estado/localizacao_estado.dart';
import '../models/enums.dart';
import '../widgets/componentes.dart';

/// Folha de filtros do protótipo (RF04, RF05 + acessibilidade e distância).
Future<void> mostrarFiltros(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => const _FiltrosFolha(),
    );

class _FiltrosFolha extends StatelessWidget {
  const _FiltrosFolha();

  static final _distancias = <double, String>{
    500: '500 m',
    1000: '1 km',
    3000: '3 km',
    5000: '5 km',
  };

  @override
  Widget build(BuildContext context) {
    final f = AreasEstado.instancia;
    final loc = LocalizacaoEstado.instancia;

    return ListenableBuilder(
      listenable: Listenable.merge([f, loc]),
      builder: (context, _) {
        final tema = Theme.of(context);
        final total = f.filtradas().length;

        Widget grupo<T>(String titulo, List<T> itens, Set<T> sel,
            String Function(T) rotulo, IconData Function(T) icone) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: tema.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final i in itens)
                FilterChip(
                  avatar: Icon(icone(i), size: 18),
                  label: Text(rotulo(i)),
                  selected: sel.contains(i),
                  onSelected: (_) => f.alternar(sel, i),
                ),
            ]),
            const SizedBox(height: 20),
          ]);
        }

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, scroll) => Column(children: [
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  Text('Filtros', style: tema.textTheme.displaySmall),
                  Text(
                    f.quantidadeFiltros == 1
                        ? '1 filtro selecionado'
                        : '${f.quantidadeFiltros} filtros selecionados',
                    style: tema.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  grupo<Atividade>('Atividades', Atividade.values, f.atividades,
                      (a) => a.rotulo, iconeAtividade),
                  grupo<Recurso>('Estrutura', Recurso.values, f.estrutura,
                      (r) => r.rotulo, iconeRecurso),
                  grupo<RecursoAcessibilidade>(
                      'Acessibilidade',
                      RecursoAcessibilidade.values,
                      f.acessibilidade,
                      (r) => r.rotulo,
                      iconeAcessibilidade),
                  Text('Distância máxima', style: tema.textTheme.titleLarge),
                  if (!loc.temPosicao)
                    Text('Ative a localização para usar este filtro.',
                        style: tema.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    for (final e in _distancias.entries)
                      ChoiceChip(
                        label: Text(e.value),
                        selected: f.distanciaMaxima == e.key,
                        onSelected: loc.temPosicao
                            ? (s) => f.definirDistancia(s ? e.key : null)
                            : null,
                      ),
                  ]),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: f.limparFiltros, child: const Text('Limpar')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Mostrar $total ${total == 1 ? 'local' : 'locais'}'),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }
}
