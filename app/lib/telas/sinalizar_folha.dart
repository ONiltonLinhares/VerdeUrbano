import 'package:material_ui/material_ui.dart';

import '../core/navegacao.dart';
import '../core/validadores.dart';
import '../data/sinalizacoes_repositorio.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../widgets/componentes.dart';

/// RF10 — sinalizar informação incorreta ou desatualizada (exige login).
Future<void> mostrarSinalizar(BuildContext context, AreaVerde area) async {
  if (!await garantirLogin(context, motivo: 'Entre para sinalizar uma informação.')) {
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => _SinalizarFolha(area: area),
  );
}

class _SinalizarFolha extends StatefulWidget {
  const _SinalizarFolha({required this.area});
  final AreaVerde area;

  @override
  State<_SinalizarFolha> createState() => _SinalizarFolhaState();
}

class _SinalizarFolhaState extends State<_SinalizarFolha> {
  static const _motivos = [
    'Horário errado',
    'Acessibilidade incorreta',
    'Estrutura ou atividades incorretas',
    'Local fechado ou não existe',
    'Outro',
  ];

  final _form = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  String _motivo = _motivos.first;
  bool _enviando = false;

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      // O motivo vai no início do texto: o modelo Sinalizacao guarda só a descrição.
      await SinalizacoesRepositorio.instancia.enviar(
        areaId: widget.area.id,
        autorId: Sessao.instancia.uid!,
        descricao: '[$_motivo] ${_descricao.text.trim()}',
      );
      if (!mounted) return;
      avisar(context, 'Obrigado! A equipe vai revisar a informação.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sinalizar informação', style: tema.textTheme.headlineSmall),
            Text(widget.area.nome, style: tema.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in _motivos)
                ChoiceChip(
                  label: Text(m),
                  selected: _motivo == m,
                  onSelected: (_) => setState(() => _motivo = m),
                ),
            ]),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricao,
              maxLines: 3,
              maxLength: 450,
              decoration: const InputDecoration(
                labelText: 'O que está errado?',
                hintText: 'Ex.: o parque agora fecha às 18h',
              ),
              validator: (v) => Validadores.texto(v, min: 5, max: 450),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _enviando ? null : _enviar,
                child: _enviando ? const GirandoNoBotao() : const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
