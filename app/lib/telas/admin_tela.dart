import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../data/areas_repositorio.dart';
import '../data/dados_exemplo.dart';
import '../data/sinalizacoes_repositorio.dart';
import '../estado/areas_estado.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import '../models/sinalizacao.dart';
import '../widgets/componentes.dart';
import 'area_form_tela.dart';

/// Área do administrador (controle de acesso: papel `admin`).
/// Cadastrar locais, aprovar sugestões e moderar sinalizações (RF10).
class AdminTela extends StatefulWidget {
  const AdminTela({super.key});

  @override
  State<AdminTela> createState() => _AdminTelaState();
}

class _AdminTelaState extends State<AdminTela> {
  late final Stream<List<AreaVerde>> _pendentes =
      AreasRepositorio.instancia.observarPendentes();
  late final Stream<List<Sinalizacao>> _sinalizacoes =
      SinalizacoesRepositorio.instancia.observarPendentes();

  Future<void> _executar(Future<void> Function() acao, String sucesso) async {
    try {
      await acao();
      if (mounted) avisar(context, sucesso);
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controle de acesso na tela; o firestore.rules garante no banco.
    if (!Sessao.instancia.isAdmin) {
      return Scaffold(
        appBar: AppBar(),
        body: const EstadoVazio(
          icone: Icons.lock_outline,
          titulo: 'Acesso restrito',
          mensagem: 'Esta área é só para administradores.',
        ),
      );
    }
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Administração')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'nova-area',
        onPressed: () => abrir(context, const AreaFormTela()),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Nova área'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 96), children: [
        const TituloSecao('Sugestões de moradores'),
        StreamBuilder<List<AreaVerde>>(
          stream: _pendentes,
          builder: (context, snap) {
            if (snap.hasError) return Text(snap.error.toString());
            final lista = snap.data ?? const <AreaVerde>[];
            if (lista.isEmpty) {
              return Text('Nenhuma sugestão pendente.', style: tema.textTheme.bodyMedium);
            }
            return Column(children: [
              for (final a in lista)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(iconeTipo(a.tipo), color: Cores.floresta),
                    title: Text(a.nome),
                    subtitle: Text('${a.bairro}, ${a.cidade}'),
                    onTap: () => abrirLocal(context, a.id),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        tooltip: 'Publicar',
                        icon: const Icon(Icons.check_circle_outline, color: Cores.floresta),
                        onPressed: () => _executar(
                          () => AreasRepositorio.instancia
                              .alterarStatus(a.id, StatusArea.publicada),
                          'Local publicado',
                        ),
                      ),
                      IconButton(
                        tooltip: 'Recusar',
                        icon: const Icon(Icons.cancel_outlined, color: Cores.terra),
                        onPressed: () => _executar(
                          () => AreasRepositorio.instancia
                              .alterarStatus(a.id, StatusArea.desativada),
                          'Sugestão recusada',
                        ),
                      ),
                    ]),
                  ),
                ),
            ]);
          },
        ),
        const SizedBox(height: 28),
        const TituloSecao('Sinalizações pendentes'),
        StreamBuilder<List<Sinalizacao>>(
          stream: _sinalizacoes,
          builder: (context, snap) {
            if (snap.hasError) return Text(snap.error.toString());
            final lista = snap.data ?? const <Sinalizacao>[];
            if (lista.isEmpty) {
              return Text('Tudo em dia.', style: tema.textTheme.bodyMedium);
            }
            return Column(children: [
              for (final s in lista)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(AreasEstado.instancia.porId(s.areaId)?.nome ?? 'Local ${s.areaId}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(formatarDataHora(s.criadoEm), style: tema.textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      Text(s.descricao),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        OutlinedButton(
                          onPressed: () => abrirLocal(context, s.areaId),
                          child: const Text('Abrir local'),
                        ),
                        FilledButton(
                          onPressed: () => _executar(
                            () => SinalizacoesRepositorio.instancia
                                .alterarStatus(s.id, StatusSinalizacao.resolvida),
                            'Marcada como resolvida',
                          ),
                          child: const Text('Resolvida'),
                        ),
                        TextButton(
                          onPressed: () => _executar(
                            () => SinalizacoesRepositorio.instancia
                                .alterarStatus(s.id, StatusSinalizacao.rejeitada),
                            'Sinalização rejeitada',
                          ),
                          child: const Text('Rejeitar'),
                        ),
                      ]),
                    ]),
                  ),
                ),
            ]);
          },
        ),
        const SizedBox(height: 28),
        const TituloSecao('Dados de exemplo'),
        Text('Cadastra os 5 locais do protótipo (para testes e apresentação).',
            style: tema.textTheme.bodyMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _executar(DadosExemplo.popular, 'Locais de exemplo adicionados'),
          icon: const Icon(Icons.dataset_outlined),
          label: const Text('Adicionar locais de exemplo'),
        ),
      ]),
    );
  }
}
