import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../data/areas_repositorio.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import '../widgets/componentes.dart';
import 'admin_tela.dart';
import 'area_form_tela.dart';

/// Perfil (CRUD 1 — consultar, atualizar e excluir a conta), sugestões de
/// local feitas pelo usuário e acesso à área do administrador.
class PerfilTela extends StatefulWidget {
  const PerfilTela({super.key});

  @override
  State<PerfilTela> createState() => _PerfilTelaState();
}

class _PerfilTelaState extends State<PerfilTela> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final Set<Atividade> _preferencias = {};
  bool _preenchido = false;
  bool _salvando = false;
  Stream<List<AreaVerde>>? _sugestoes;

  @override
  void initState() {
    super.initState();
    final uid = Sessao.instancia.uid;
    if (uid != null) {
      _sugestoes = AreasRepositorio.instancia.observarMinhasSugestoes(uid);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await Sessao.instancia.atualizarPerfil(
        nome: _nome.text,
        preferencias: _preferencias.toList(),
      );
      if (mounted) avisar(context, 'Perfil atualizado');
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluirConta() async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir sua conta?',
      mensagem: 'Seu perfil, favoritos e fotos serão apagados. Suas avaliações '
          'e eventos continuam, mas com o nome "Usuário removido". '
          'O diário fica só neste aparelho e não é afetado.',
      acao: 'Excluir conta',
    );
    if (!ok || !mounted) return;
    try {
      await Sessao.instancia.excluirConta();
      if (!mounted) return;
      avisar(context, 'Conta excluída');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Sessao.instancia,
      builder: (context, _) {
        final sessao = Sessao.instancia;
        if (!sessao.logado) {
          return Scaffold(
            appBar: AppBar(),
            body: const EstadoVazio(
              icone: Icons.person_outline,
              titulo: 'Você saiu da conta',
              mensagem: 'Entre de novo para ver seu perfil.',
            ),
          );
        }
        final perfil = sessao.perfil;
        if (!_preenchido && (perfil != null || sessao.user != null)) {
          _nome.text = perfil?.nome ?? sessao.user?.displayName ?? '';
          _preferencias.addAll(perfil?.preferencias ?? const []);
          _preenchido = true;
        }
        final tema = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: const Text('Meu perfil')),
          body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text(sessao.user?.email ?? '', style: tema.textTheme.bodyMedium),
              if (sessao.isAdmin)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(label: Text('Administrador')),
                  ),
                ),
              if (perfil != null)
                Text('Conta criada em ${formatarData(perfil.criadoEm)}',
                    style: tema.textTheme.bodyMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nome,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: Validadores.nome,
              ),
              const SizedBox(height: 8),
              Text('Atividades preferidas', style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final a in Atividade.values)
                  FilterChip(
                    avatar: Icon(iconeAtividade(a), size: 18),
                    label: Text(a.rotulo),
                    selected: _preferencias.contains(a),
                    onSelected: (s) => setState(
                        () => s ? _preferencias.add(a) : _preferencias.remove(a)),
                  ),
              ]),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando ? const GirandoNoBotao() : const Text('Salvar alterações'),
              ),
              const SizedBox(height: 28),
              TituloSecao(
                'Minhas sugestões de local',
                acao: TextButton.icon(
                  onPressed: () => abrir(context, const AreaFormTela()),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Sugerir'),
                ),
              ),
              StreamBuilder<List<AreaVerde>>(
                stream: _sugestoes,
                builder: (context, snap) {
                  final lista = snap.data ?? const <AreaVerde>[];
                  if (lista.isEmpty) {
                    return Text(
                      'Conhece uma praça ou horta que não está no app? Sugira! '
                      'Ela aparece para todos depois da revisão.',
                      style: tema.textTheme.bodyMedium,
                    );
                  }
                  return Column(children: [
                    for (final a in lista)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(iconeTipo(a.tipo), color: Cores.floresta),
                        title: Text(a.nome),
                        subtitle: Text(switch (a.status) {
                          StatusArea.pendente => 'Aguardando revisão',
                          StatusArea.publicada => 'Publicada',
                          StatusArea.desativada => 'Não aprovada / desativada',
                        }),
                      ),
                  ]);
                },
              ),
              if (sessao.isAdmin) ...[
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () => abrir(context, const AdminTela()),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Área do administrador'),
                ),
              ],
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  sessao.sair();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: tema.colorScheme.error),
                onPressed: _excluirConta,
                child: const Text('Excluir minha conta'),
              ),
            ]),
          ),
        );
      },
    );
  }
}
