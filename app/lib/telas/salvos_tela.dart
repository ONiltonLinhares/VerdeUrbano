import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../data/favoritos_repositorio.dart';
import '../data/offline_repositorio.dart';
import '../estado/areas_estado.dart';
import '../estado/localizacao_estado.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/favorito.dart';
import '../widgets/componentes.dart';
import 'login_tela.dart';

/// Aba Salvos do protótipo: "Favoritos · 3" e "Offline · 2".
class SalvosTela extends StatelessWidget {
  const SalvosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([Sessao.instancia, OfflineRepositorio.instancia]),
      builder: (context, _) {
        final sessao = Sessao.instancia;
        final offline = OfflineRepositorio.instancia;
        return DefaultTabController(
          length: 2,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Salvos', style: Theme.of(context).textTheme.displaySmall),
              ),
            ),
            TabBar(tabs: [
              const Tab(text: 'Favoritos'),
              Tab(text: 'Offline · ${offline.locais.length}'),
            ]),
            Expanded(
              child: TabBarView(children: [
                sessao.logado
                    ? _Favoritos(key: ValueKey(sessao.uid), uid: sessao.uid!)
                    : EstadoVazio(
                        icone: Icons.favorite_border,
                        titulo: 'Entre para ver seus favoritos',
                        mensagem: 'Com uma conta, seus favoritos ficam salvos em '
                            'qualquer aparelho.',
                        acao: FilledButton(
                          onPressed: () =>
                              abrir(context, const LoginTela(fecharAoEntrar: true)),
                          child: const Text('Entrar'),
                        ),
                      ),
                const _Offline(),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _Favoritos extends StatefulWidget {
  const _Favoritos({super.key, required this.uid});
  final String uid;

  @override
  State<_Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<_Favoritos> {
  late final Stream<List<Favorito>> _stream =
      FavoritosRepositorio.instancia.observar(widget.uid);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AreasEstado.instancia, LocalizacaoEstado.instancia]),
      builder: (context, _) => StreamBuilder<List<Favorito>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const ErroCarregamento(
                mensagem: 'Não foi possível carregar seus favoritos.');
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          // O favorito guarda só o id: os dados vêm da área já carregada,
          // então nunca ficam desatualizados (modelagem-dados.md, seção 3).
          final areas = snap.data!
              .map((f) => AreasEstado.instancia.porId(f.areaId))
              .whereType<AreaVerde>()
              .toList();
          if (areas.isEmpty) {
            return const EstadoVazio(
              icone: Icons.favorite_border,
              titulo: 'Nenhum favorito ainda',
              mensagem: 'Toque em "Salvar" na página de um local para guardá-lo aqui.',
            );
          }
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text('Favoritos · ${areas.length}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            for (final a in areas)
              _ItemSalvo(
                area: a,
                rotuloRemover: 'Remover dos favoritos',
                aoRemover: () => FavoritosRepositorio.instancia.remover(
                  widget.uid,
                  a.id,
                  aoFalhar: (m) => avisar(context, m),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

class _Offline extends StatelessWidget {
  const _Offline();

  @override
  Widget build(BuildContext context) {
    final offline = OfflineRepositorio.instancia;
    final locais = offline.locais;
    if (locais.isEmpty) {
      return const EstadoVazio(
        icone: Icons.download_outlined,
        titulo: 'Nada salvo offline',
        mensagem: 'Toque em "Baixar offline" na página de um local para '
            'consultá-lo sem internet.',
      );
    }
    final kb = formatarNota(offline.bytesUsados / 1024);
    return ListenableBuilder(
      listenable: LocalizacaoEstado.instancia,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Text(
          'Ocupando ~$kb KB · até ${OfflineRepositorio.maxLocais} locais; '
          'os mais antigos saem automaticamente.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final l in locais)
          _ItemSalvo(
            area: l.area,
            detalhe: 'Baixado em ${formatarDataHora(l.baixadoEm)}',
            rotuloRemover: 'Remover do offline',
            aoRemover: () => offline.remover(l.area.id),
          ),
      ]),
    );
  }
}

/// "Parque das Águas Claras — Parque · 650 m · aberto até 20h".
class _ItemSalvo extends StatelessWidget {
  const _ItemSalvo({
    required this.area,
    required this.aoRemover,
    required this.rotuloRemover,
    this.detalhe,
  });

  final AreaVerde area;
  final VoidCallback aoRemover;
  final String rotuloRemover;
  final String? detalhe;

  @override
  Widget build(BuildContext context) {
    final dist = LocalizacaoEstado.instancia.distanciaAte(area);
    final linha = [
      area.tipo.rotulo,
      if (dist != null) formatarDistancia(dist),
      situacaoHorario(area.horario, DateTime.now()).toLowerCase(),
    ].join(' · ');
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 64,
          height: 64,
          child: FotoArea(area: area, altura: 64, raio: BorderRadius.circular(12)),
        ),
        title: Text(area.nome,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Cores.texto)),
        subtitle: Text([linha, ?detalhe].join('\n')),
        isThreeLine: detalhe != null,
        trailing: IconButton(
          tooltip: rotuloRemover,
          icon: const Icon(Icons.delete_outline),
          onPressed: aoRemover,
        ),
        onTap: () => abrirLocal(context, area.id),
      ),
    );
  }
}
