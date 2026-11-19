import 'package:material_ui/material_ui.dart';

import '../core/acoes_externas.dart';
import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../data/areas_repositorio.dart';
import '../data/avaliacoes_repositorio.dart';
import '../data/eventos_repositorio.dart';
import '../data/favoritos_repositorio.dart';
import '../data/fotos_repositorio.dart';
import '../data/offline_repositorio.dart';
import '../estado/localizacao_estado.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/avaliacao.dart';
import '../models/enums.dart';
import '../models/evento.dart';
import '../models/favorito.dart';
import '../models/foto.dart';
import '../widgets/componentes.dart';
import 'area_form_tela.dart';
import 'avaliacao_tela.dart';
import 'evento_tela.dart';
import 'foto_tela.dart';
import 'registro_diario_tela.dart';
import 'rota_tela.dart';
import 'sinalizar_folha.dart';

/// Página do local (RF06–RF12, RF14, RF17 e CRUDs 3, 4 e 5).
/// Ordem do protótipo: o que é → Rota → Salvar/Offline → atividades →
/// estrutura → acessibilidade → fonte e data → avaliações.
class LocalTela extends StatefulWidget {
  const LocalTela({super.key, required this.areaId});
  final String areaId;

  @override
  State<LocalTela> createState() => _LocalTelaState();
}

class _LocalTelaState extends State<LocalTela> {
  // Criado uma vez: não reabre a consulta a cada rebuild.
  late final Stream<AreaVerde?> _stream =
      AreasRepositorio.instancia.observar(widget.areaId);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineRepositorio.instancia,
      builder: (context, _) => StreamBuilder<AreaVerde?>(
        stream: _stream,
        builder: (context, snap) {
          // Sem internet e sem cache: usa a cópia salva no aparelho (RF12).
          final copia = OfflineRepositorio.instancia.obter(widget.areaId);
          final area = snap.data ?? copia?.area;
          final usandoCopia = snap.data == null && copia != null;

          if (area == null) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return Scaffold(
              appBar: AppBar(),
              body: snap.hasError
                  ? const ErroCarregamento(
                      mensagem: 'Sem conexão, e este local não foi salvo para uso offline.')
                  : const EstadoVazio(
                      icone: Icons.wrong_location_outlined,
                      titulo: 'Local não encontrado',
                      mensagem: 'Ele pode ter sido removido.',
                    ),
            );
          }
          return _Conteudo(
            area: area,
            baixadoEm: usandoCopia ? copia.baixadoEm : null,
          );
        },
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.area, this.baixadoEm});
  final AreaVerde area;
  final DateTime? baixadoEm;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([Sessao.instancia, LocalizacaoEstado.instancia]),
      builder: (context, _) {
        final sessao = Sessao.instancia;
        final dist = LocalizacaoEstado.instancia.distanciaAte(area);
        final aberto = area.estaAberta(DateTime.now());

        return Scaffold(
          body: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: Cores.floresta,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  tooltip: 'Compartilhar',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => AcoesExternas.compartilhar(area),
                ),
                if (sessao.isAdmin) _MenuAdmin(area: area),
              ],
              flexibleSpace: FlexibleSpaceBar(background: _Galeria(area: area)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList.list(children: [
                if (baixadoEm != null)
                  _Aviso('Sem internet. Você está vendo a cópia offline salva em '
                      '${formatarDataHora(baixadoEm!)}.'),
                if (area.status != StatusArea.publicada)
                  _Aviso(area.status == StatusArea.pendente
                      ? 'Sugestão aguardando revisão: ainda não aparece para os outros.'
                      : 'Local desativado: não aparece no mapa.'),
                Sobretitulo(area),
                const SizedBox(height: 4),
                Text(area.nome, style: tema.textTheme.displaySmall),
                const SizedBox(height: 8),
                Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  NotaArea(area.resumo),
                  if (dist != null) Text('· ${formatarDistancia(dist)} de você'),
                ]),
                const SizedBox(height: 4),
                Text(
                  '${aberto ? 'Aberto agora' : 'Fechado agora'} · ${descricaoHorario(area.horario)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: aberto ? Cores.floresta : Cores.terra,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${area.endereco} · ${area.bairro}, ${area.cidade}',
                    style: tema.textTheme.bodyLarge),
                const SizedBox(height: 20),
                // Ação principal: Rota (3º toque do RNF01).
                FilledButton.icon(
                  onPressed: () => abrir(context, RotaTela(area: area)),
                  icon: const Icon(Icons.directions_walk),
                  label: Text(dist == null
                      ? 'Rota'
                      : 'Rota · ${minutosEstimados(dist, 'a_pe')} min a pé'),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _BotaoFavorito(area: area)),
                  const SizedBox(width: 12),
                  Expanded(child: _BotaoOffline(area: area)),
                ]),
                const SizedBox(height: 28),
                const TituloSecao('Atividades'),
                if (area.atividades.isEmpty)
                  Text('Nenhuma atividade informada.', style: tema.textTheme.bodyMedium)
                else
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final a in area.atividades)
                      Chip(
                        avatar: Icon(iconeAtividade(a), size: 18),
                        label: Text(a.rotulo),
                      ),
                  ]),
                const SizedBox(height: 24),
                const TituloSecao('Estrutura'),
                for (final r in Recurso.values)
                  LinhaDisponibilidade(
                    icone: iconeRecurso(r),
                    rotulo: r.rotulo,
                    valor: area.estrutura[r] ?? Disponibilidade.naoInformado,
                  ),
                const SizedBox(height: 24),
                // Bloco de acessibilidade em destaque (RF07, RNF08).
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Cores.floresta, width: 1.5),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const TituloSecao('Acessibilidade'),
                    for (final r in RecursoAcessibilidade.values)
                      LinhaDisponibilidade(
                        icone: iconeAcessibilidade(r),
                        rotulo: r.rotulo,
                        valor: area.acessibilidade[r] ?? Disponibilidade.naoInformado,
                      ),
                    const Divider(height: 24),
                    const LegendaDisponibilidade(),
                  ]),
                ),
                const SizedBox(height: 16),
                // RF08: origem e data da informação.
                Text('Fonte: ${area.fonte}', style: tema.textTheme.bodyMedium),
                Text('Atualizado em: ${formatarData(area.atualizadoEm)}',
                    style: tema.textTheme.bodyMedium),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => mostrarSinalizar(context, area),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Sinalizar informação incorreta'),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => abrir(context, RegistroDiarioTela(area: area)),
                  icon: const Icon(Icons.book_outlined),
                  label: const Text('Registrar como me senti aqui'),
                ),
                const SizedBox(height: 28),
                _SecaoFotos(area: area),
                const SizedBox(height: 28),
                _SecaoEventos(area: area),
                const SizedBox(height: 28),
                _SecaoAvaliacoes(area: area),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Cores.areia, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.info_outline, color: Cores.terra),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ]),
      );
}

class _Galeria extends StatefulWidget {
  const _Galeria({required this.area});
  final AreaVerde area;

  @override
  State<_Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<_Galeria> {
  int _atual = 0;

  @override
  Widget build(BuildContext context) {
    final fotos = widget.area.fotos;
    final total = fotos.isEmpty ? 1 : fotos.length;
    return Stack(fit: StackFit.expand, children: [
      PageView.builder(
        itemCount: total,
        onPageChanged: (i) => setState(() => _atual = i),
        itemBuilder: (_, i) => FotoArea(
            area: widget.area, indice: i, altura: 300, raio: BorderRadius.zero),
      ),
      if (fotos.length > 1)
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(20)),
            child: Text('${_atual + 1} / $total fotos',
                style: const TextStyle(color: Colors.white)),
          ),
        ),
    ]);
  }
}

// ---------------- Favorito (CRUD 6) ----------------

class _BotaoFavorito extends StatefulWidget {
  const _BotaoFavorito({required this.area});
  final AreaVerde area;

  @override
  State<_BotaoFavorito> createState() => _BotaoFavoritoState();
}

class _BotaoFavoritoState extends State<_BotaoFavorito> {
  String? _uid;
  Stream<List<Favorito>>? _stream;

  @override
  Widget build(BuildContext context) {
    final uid = Sessao.instancia.uid;
    if (uid != _uid) {
      _uid = uid;
      _stream = uid == null ? null : FavoritosRepositorio.instancia.observar(uid);
    }

    Widget botao(bool salvo) => OutlinedButton.icon(
          onPressed: () async {
            if (!await garantirLogin(context,
                motivo: 'Entre para salvar seus favoritos.')) {
              return;
            }
            final id = Sessao.instancia.uid!;
            void falhou(String m) {
              if (context.mounted) avisar(context, m);
            }
            if (salvo) {
              FavoritosRepositorio.instancia.remover(id, widget.area.id, aoFalhar: falhou);
              if (context.mounted) avisar(context, 'Removido dos favoritos');
            } else {
              FavoritosRepositorio.instancia.adicionar(id, widget.area.id, aoFalhar: falhou);
              if (context.mounted) avisar(context, 'Salvo nos favoritos');
            }
          },
          icon: Icon(salvo ? Icons.favorite : Icons.favorite_border),
          label: Text(salvo ? 'Salvo' : 'Salvar'),
        );

    if (_stream == null) return botao(false);
    return StreamBuilder<List<Favorito>>(
      stream: _stream,
      builder: (_, snap) =>
          botao(snap.data?.any((f) => f.areaId == widget.area.id) ?? false),
    );
  }
}

// ---------------- Offline (RF11) ----------------

class _BotaoOffline extends StatelessWidget {
  const _BotaoOffline({required this.area});
  final AreaVerde area;

  @override
  Widget build(BuildContext context) {
    final offline = OfflineRepositorio.instancia;
    final salvo = offline.contem(area.id);
    return OutlinedButton.icon(
      onPressed: () async {
        if (salvo) {
          await offline.remover(area.id);
          if (context.mounted) avisar(context, 'Removido do offline');
        } else {
          await offline.salvar(area);
          if (context.mounted) avisar(context, 'Salvo para consultar sem internet');
        }
      },
      icon: Icon(salvo ? Icons.download_done : Icons.download_outlined),
      label: Text(salvo ? 'Offline' : 'Baixar offline'),
    );
  }
}

// ---------------- Fotos da comunidade (CRUD 4) ----------------

class _SecaoFotos extends StatefulWidget {
  const _SecaoFotos({required this.area});
  final AreaVerde area;

  @override
  State<_SecaoFotos> createState() => _SecaoFotosState();
}

class _SecaoFotosState extends State<_SecaoFotos> {
  late final Stream<List<Foto>> _stream =
      FotosRepositorio.instancia.observar(widget.area.id);

  Future<void> _enviar() async {
    if (!await garantirLogin(context, motivo: 'Entre para enviar fotos.')) return;
    if (mounted) abrir(context, FotoTela(areaId: widget.area.id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TituloSecao(
        'Fotos da comunidade',
        acao: TextButton.icon(
          onPressed: _enviar,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Enviar'),
        ),
      ),
      StreamBuilder<List<Foto>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Text('Não foi possível carregar as fotos agora.');
          }
          final fotos = snap.data ?? const <Foto>[];
          if (fotos.isEmpty) {
            return Text('Ainda não há fotos. Que tal enviar a primeira?',
                style: Theme.of(context).textTheme.bodyMedium);
          }
          return SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fotos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final f = fotos[i];
                return GestureDetector(
                  onTap: () => abrir(context, FotoTela(areaId: widget.area.id, foto: f)),
                  child: SizedBox(
                    width: 150,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      bytesDaFoto(f) == null
                          ? Container(
                              height: 130,
                              color: Cores.areia,
                              child: const Center(child: Icon(Icons.broken_image_outlined)),
                            )
                          : ImagemBytes(bytesDaFoto(f)!, altura: 130, legenda: f.legenda),
                      const SizedBox(height: 4),
                      Text(f.legenda.isEmpty ? f.autorNome : f.legenda,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),
    ]);
  }
}

// ---------------- Eventos e mutirões (CRUD 5) ----------------

class _SecaoEventos extends StatefulWidget {
  const _SecaoEventos({required this.area});
  final AreaVerde area;

  @override
  State<_SecaoEventos> createState() => _SecaoEventosState();
}

class _SecaoEventosState extends State<_SecaoEventos> {
  late final Stream<List<Evento>> _stream =
      EventosRepositorio.instancia.observarProximos(widget.area.id);

  Future<void> _criar() async {
    if (!await garantirLogin(context, motivo: 'Entre para criar um evento.')) return;
    if (mounted) abrir(context, EventoTela(area: widget.area));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TituloSecao(
        'Eventos e mutirões',
        acao: TextButton.icon(
          onPressed: _criar,
          icon: const Icon(Icons.event_outlined),
          label: const Text('Criar'),
        ),
      ),
      StreamBuilder<List<Evento>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Text('Não foi possível carregar os eventos agora.');
          }
          final eventos = snap.data ?? const <Evento>[];
          if (eventos.isEmpty) {
            return Text('Nenhum evento marcado. Ioga, corrida, plantio? Organize um!',
                style: tema.textTheme.bodyMedium);
          }
          return Column(children: [
            for (final e in eventos)
              Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Cores.floresta),
                  title: Text(
                    e.status == StatusEvento.cancelado ? '${e.titulo} (cancelado)' : e.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      decoration: e.status == StatusEvento.cancelado
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text('${e.tipo.rotulo} · ${formatarDataHora(e.inicio)}\n'
                      'por ${e.organizadorNome}'),
                  isThreeLine: true,
                  trailing: e.podeEditar(Sessao.instancia.uid)
                      ? const Icon(Icons.edit_outlined)
                      : null,
                  onTap: () => _detalhes(context, e),
                ),
              ),
          ]);
        },
      ),
    ]);
  }

  void _detalhes(BuildContext context, Evento e) {
    final dono = e.podeEditar(Sessao.instancia.uid);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.titulo, style: Theme.of(c).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('${e.tipo.rotulo} · ${formatarDataHora(e.inicio)} até '
                '${doisDigitos(e.fim.hour)}h${doisDigitos(e.fim.minute)}'),
            Text('Organizado por ${e.organizadorNome}'),
            if (e.descricao.isNotEmpty) ...[const SizedBox(height: 10), Text(e.descricao)],
            if (dono) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(c);
                  abrir(context, EventoTela(area: widget.area, evento: e));
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar evento'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------- Avaliações (CRUD 3) ----------------

class _SecaoAvaliacoes extends StatefulWidget {
  const _SecaoAvaliacoes({required this.area});
  final AreaVerde area;

  @override
  State<_SecaoAvaliacoes> createState() => _SecaoAvaliacoesState();
}

class _SecaoAvaliacoesState extends State<_SecaoAvaliacoes> {
  late final Stream<List<Avaliacao>> _stream =
      AvaliacoesRepositorio.instancia.observar(widget.area.id);

  Future<void> _avaliar() async {
    if (!await garantirLogin(context, motivo: 'Entre para publicar sua avaliação.')) {
      return;
    }
    if (mounted) abrir(context, AvaliacaoTela(area: widget.area));
  }

  Future<void> _moderar(Avaliacao a) async {
    final ok = await confirmar(context,
        titulo: 'Remover a avaliação de ${a.autorNome}?',
        mensagem: 'Use para conteúdo ofensivo ou falso. A nota do local é recalculada.');
    if (!ok || !mounted) return;
    try {
      await AvaliacoesRepositorio.instancia.excluir(widget.area.id, a.autorId);
      if (mounted) avisar(context, 'Avaliação removida');
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final r = widget.area.resumo;
    final sessao = Sessao.instancia;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TituloSecao(
        'Avaliações',
        acao: Text('${r.total} no total', style: tema.textTheme.bodyMedium),
      ),
      if (r.total > 0)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Text(formatarNota(r.media), style: tema.textTheme.displaySmall),
            Text('de 5', style: tema.textTheme.bodyMedium),
          ]),
          const SizedBox(width: 24),
          Expanded(
            child: Column(children: [
              _LinhaMedia('Limpeza', r.mediaLimpeza),
              _LinhaMedia('Conservação', r.mediaConservacao),
              _LinhaMedia('Acessibilidade', r.mediaAcessibilidade),
            ]),
          ),
        ]),
      const SizedBox(height: 8),
      Text(
        'Relatos são experiências de usuários e não garantem segurança ou acessibilidade.',
        style: tema.textTheme.bodyMedium?.copyWith(fontSize: 13),
      ),
      const SizedBox(height: 12),
      StreamBuilder<List<Avaliacao>>(
        stream: _stream,
        builder: (context, snap) {
          final lista = snap.data ?? const <Avaliacao>[];
          final minha = lista.where((a) => a.autorId == sessao.uid).firstOrNull;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FilledButton.tonalIcon(
              onPressed: _avaliar,
              icon: Icon(minha == null ? Icons.rate_review_outlined : Icons.edit_outlined),
              label: Text(minha == null ? 'Avaliar este local' : 'Editar minha avaliação'),
            ),
            const SizedBox(height: 12),
            if (snap.hasError)
              const Text('Não foi possível carregar as avaliações agora.')
            else if (!snap.hasData)
              const Center(child: CircularProgressIndicator())
            else if (lista.isEmpty)
              const Text('Ainda não há avaliações. Seja a primeira pessoa!')
            else
              for (final a in lista)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          child: Text(a.autorNome,
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        Text(tempoRelativo(a.criadoEm), style: tema.textTheme.bodyMedium),
                        if (sessao.isAdmin && a.autorId != sessao.uid)
                          IconButton(
                            tooltip: 'Remover (moderação)',
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _moderar(a),
                          ),
                      ]),
                      Text('★' * a.nota + '☆' * (5 - a.nota),
                          semanticsLabel: 'Nota ${a.nota} de 5',
                          style: const TextStyle(color: Cores.estrela, fontSize: 16)),
                      if (a.comentario.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(a.comentario, style: tema.textTheme.bodyLarge),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Limpeza: ${a.notaLimpeza} · Conservação: ${a.notaConservacao} · '
                        'Acessibilidade: ${a.notaAcessibilidade}',
                        style: tema.textTheme.bodyMedium?.copyWith(fontSize: 13),
                      ),
                    ]),
                  ),
                ),
          ]);
        },
      ),
    ]);
  }
}

class _LinhaMedia extends StatelessWidget {
  const _LinhaMedia(this.rotulo, this.valor);
  final String rotulo;
  final double valor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(rotulo)),
          Text(formatarNota(valor), style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );
}

// ---------------- Menu do administrador (CRUD 2) ----------------

class _MenuAdmin extends StatelessWidget {
  const _MenuAdmin({required this.area});
  final AreaVerde area;

  @override
  Widget build(BuildContext context) {
    final repo = AreasRepositorio.instancia;
    return PopupMenuButton<String>(
      tooltip: 'Administração',
      onSelected: (op) async {
        try {
          switch (op) {
            case 'editar':
              await abrir(context, AreaFormTela(area: area));
            case 'publicar':
              await repo.alterarStatus(area.id, StatusArea.publicada);
              if (context.mounted) avisar(context, 'Local publicado');
            case 'desativar':
              await repo.alterarStatus(area.id, StatusArea.desativada);
              if (context.mounted) avisar(context, 'Local desativado');
            case 'excluir':
              final ok = await confirmar(context,
                  titulo: 'Excluir "${area.nome}" definitivamente?',
                  mensagem: 'Avaliações, fotos e eventos do local também serão '
                      'apagados. Para só esconder do mapa, use "Desativar".');
              if (!ok) return;
              await repo.excluirDefinitivamente(area.id);
              if (context.mounted) {
                avisar(context, 'Local excluído');
                Navigator.of(context).pop();
              }
          }
        } catch (e) {
          if (context.mounted) avisar(context, e.toString());
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'editar', child: Text('Editar local')),
        if (area.status != StatusArea.publicada)
          const PopupMenuItem(value: 'publicar', child: Text('Publicar')),
        if (area.status == StatusArea.publicada)
          const PopupMenuItem(value: 'desativar', child: Text('Desativar (esconder)')),
        const PopupMenuItem(value: 'excluir', child: Text('Excluir definitivamente')),
      ],
    );
  }
}
