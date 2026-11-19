import 'package:material_ui/material_ui.dart';

import '../core/navegacao.dart';
import '../core/validadores.dart';
import '../data/avaliacoes_repositorio.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/avaliacao.dart';
import '../widgets/componentes.dart';

/// Criar, editar e excluir a própria avaliação (CRUD 3, RF09).
/// Uma por pessoa por local: reabrir esta tela edita a anterior.
class AvaliacaoTela extends StatefulWidget {
  const AvaliacaoTela({super.key, required this.area});
  final AreaVerde area;

  @override
  State<AvaliacaoTela> createState() => _AvaliacaoTelaState();
}

class _AvaliacaoTelaState extends State<AvaliacaoTela> {
  final _form = GlobalKey<FormState>();
  final _comentario = TextEditingController();
  int _nota = 0, _limpeza = 0, _conservacao = 0, _acessibilidade = 0;
  Avaliacao? _existente;
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final uid = Sessao.instancia.uid;
    if (uid != null) {
      final a = await AvaliacoesRepositorio.instancia.minha(widget.area.id, uid);
      if (a != null) {
        _existente = a;
        _nota = a.nota;
        _limpeza = a.notaLimpeza;
        _conservacao = a.notaConservacao;
        _acessibilidade = a.notaAcessibilidade;
        _comentario.text = a.comentario;
      }
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final sessao = Sessao.instancia;
    final uid = sessao.uid;
    if (uid == null) return;
    final agora = DateTime.now();
    setState(() => _salvando = true);
    try {
      await AvaliacoesRepositorio.instancia.salvar(Avaliacao(
        id: uid,
        areaId: widget.area.id,
        autorId: uid,
        autorNome: sessao.nomePublico,
        nota: _nota,
        notaLimpeza: _limpeza,
        notaConservacao: _conservacao,
        notaAcessibilidade: _acessibilidade,
        comentario: _comentario.text.trim(),
        criadoEm: _existente?.criadoEm ?? agora,
        atualizadoEm: agora,
      ));
      if (!mounted) return;
      avisar(context, _existente == null ? 'Avaliação publicada' : 'Avaliação atualizada');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    final ok = await confirmar(context, titulo: 'Excluir sua avaliação?');
    if (!ok || !mounted) return;
    try {
      await AvaliacoesRepositorio.instancia
          .excluir(widget.area.id, _existente!.autorId);
      if (!mounted) return;
      avisar(context, 'Avaliação excluída');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existente == null ? 'Avaliar local' : 'Editar avaliação'),
        actions: [
          if (_existente != null)
            IconButton(
              tooltip: 'Excluir avaliação',
              onPressed: _excluir,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(padding: const EdgeInsets.all(20), children: [
                Text(widget.area.nome, style: tema.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Sua avaliação é pública e aparece com seu nome.',
                    style: tema.textTheme.bodyMedium),
                const SizedBox(height: 16),
                CampoEstrelas(
                    rotulo: 'Nota geral',
                    valor: _nota,
                    aoMudar: (v) => setState(() => _nota = v)),
                CampoEstrelas(
                    rotulo: 'Limpeza',
                    valor: _limpeza,
                    aoMudar: (v) => setState(() => _limpeza = v)),
                CampoEstrelas(
                    rotulo: 'Conservação',
                    valor: _conservacao,
                    aoMudar: (v) => setState(() => _conservacao = v)),
                CampoEstrelas(
                    rotulo: 'Acessibilidade',
                    valor: _acessibilidade,
                    aoMudar: (v) => setState(() => _acessibilidade = v)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _comentario,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Como foi sua visita? (opcional)',
                    hintText: 'Iluminação, limpeza, se você se sentiu segura(o)…',
                  ),
                  validator: (v) => Validadores.texto(v, max: 500),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const GirandoNoBotao()
                      : Text(_existente == null ? 'Publicar' : 'Salvar alterações'),
                ),
              ]),
            ),
    );
  }
}
