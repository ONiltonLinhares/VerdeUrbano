import 'package:material_ui/material_ui.dart';

import '../core/navegacao.dart';
import '../core/tema.dart';
import '../estado/areas_estado.dart';
import '../estado/localizacao_estado.dart';
import '../estado/sessao.dart';
import '../models/enums.dart';
import '../widgets/area_card.dart';
import '../widgets/componentes.dart';
import 'filtros_folha.dart';
import 'login_tela.dart';
import 'perfil_tela.dart';

/// Aba Início (feed do protótipo): saudação, busca, filtros rápidos e
/// locais recomendados perto de você.
/// RNF01 — rota em 3 toques: Início → tocar no card → "Rota".
class InicioTela extends StatelessWidget {
  const InicioTela({super.key, required this.aoVerMapa});

  final VoidCallback aoVerMapa;

  @override
  Widget build(BuildContext context) {
    final estado = AreasEstado.instancia;
    final loc = LocalizacaoEstado.instancia;
    final sessao = Sessao.instancia;

    return ListenableBuilder(
      listenable: Listenable.merge([estado, loc, sessao]),
      builder: (context, _) {
        final lista = estado.filtradas();
        final tema = Theme.of(context);

        return RefreshIndicator(
          onRefresh: () async {
            estado.iniciar();
            await loc.atualizar();
          },
          child: CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList.list(children: [
                Row(children: [
                  const Icon(Icons.eco, color: Cores.floresta),
                  const SizedBox(width: 6),
                  Text('VerdeUrbano',
                      style: tema.textTheme.titleLarge?.copyWith(color: Cores.floresta)),
                  const Spacer(),
                  IconButton(
                    tooltip: sessao.logado ? 'Meu perfil' : 'Entrar',
                    icon: Icon(sessao.logado
                        ? Icons.account_circle
                        : Icons.account_circle_outlined),
                    onPressed: () => abrir(
                      context,
                      sessao.logado
                          ? const PerfilTela()
                          : const LoginTela(fecharAoEntrar: true),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text('Que tal um respiro verde hoje?',
                    style: tema.textTheme.displaySmall),
                const SizedBox(height: 4),
                Text(_subtitulo(estado, loc), style: tema.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onChanged: estado.definirBusca,
                      decoration: InputDecoration(
                        hintText: 'Parque, bairro ou cidade',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: estado.quantidadeFiltros > 0,
                    label: Text('${estado.quantidadeFiltros}'),
                    child: IconButton.filledTonal(
                      tooltip: 'Filtros',
                      iconSize: 26,
                      onPressed: () => mostrarFiltros(context),
                      icon: const Icon(Icons.tune),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Todos'),
                        selected: estado.atividades.isEmpty,
                        onSelected: (_) => estado.limparAtividades(),
                      ),
                    ),
                    for (final a in Atividade.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Icon(iconeAtividade(a), size: 18),
                          label: Text(a.rotulo),
                          selected: estado.atividades.contains(a),
                          onSelected: (_) => estado.alternar(estado.atividades, a),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Text(
                      loc.temPosicao ? 'Recomendados perto de você' : 'Áreas verdes',
                      style: tema.textTheme.headlineSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: aoVerMapa,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ver no mapa'),
                  ),
                ]),
                if (estado.usandoOffline)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Sem conexão: mostrando só os locais salvos offline.',
                        style: TextStyle(color: Cores.terra, fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(height: 8),
              ]),
            ),
            if (estado.carregando && estado.areas.isEmpty)
              const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()))
            else if (estado.erro != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErroCarregamento(
                    mensagem: estado.erro!, aoTentar: estado.iniciar),
              )
            else if (lista.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EstadoVazio(
                  icone: Icons.search_off,
                  titulo: 'Nenhum local encontrado',
                  mensagem: estado.areas.isEmpty
                      ? 'Ainda não há áreas verdes cadastradas.'
                      : 'Tente outra busca ou remova alguns filtros.',
                  acao: estado.quantidadeFiltros > 0
                      ? OutlinedButton(
                          onPressed: estado.limparFiltros,
                          child: const Text('Limpar filtros'))
                      : null,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.builder(
                  itemCount: lista.length,
                  itemBuilder: (_, i) => AreaCard(
                    area: lista[i],
                    aoTocar: () => abrirLocal(context, lista[i].id),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }

  /// "4 áreas verdes a menos de 3 km de você" (protótipo).
  String _subtitulo(AreasEstado estado, LocalizacaoEstado loc) {
    if (!loc.temPosicao) {
      final n = estado.areas.length;
      return '$n ${n == 1 ? 'área verde' : 'áreas verdes'} · ative a localização para ver a distância';
    }
    final perto = estado.areas.where((a) => (loc.distanciaAte(a) ?? 1e9) <= 3000).length;
    return '$perto ${perto == 1 ? 'área verde' : 'áreas verdes'} a menos de 3 km de você';
  }
}
