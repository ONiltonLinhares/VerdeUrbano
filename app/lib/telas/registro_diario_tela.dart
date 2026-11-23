import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../data/diario_repositorio.dart';
import '../estado/areas_estado.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import '../models/registro_diario.dart';
import 'avaliacao_tela.dart';
import 'diario_tela.dart';

/// Registro do diário (CRUD local): criar, editar e excluir.
/// [registro] preenchido = edição; [area] preenchida = novo, já com o local.
class RegistroDiarioTela extends StatefulWidget {
  const RegistroDiarioTela({super.key, this.registro, this.area});
  final RegistroDiario? registro;
  final AreaVerde? area;

  @override
  State<RegistroDiarioTela> createState() => _RegistroDiarioTelaState();
}

class _RegistroDiarioTelaState extends State<RegistroDiarioTela> {
  final _anotacao = TextEditingController();
  final _localLivre = TextEditingController();
  String? _areaId;
  Humor? _humor;
  final Set<AtividadeRealizada> _atividades = {};
  late final DateTime _dataHora = widget.registro?.dataHora ?? DateTime.now();

  bool get _editando => widget.registro != null;

  @override
  void initState() {
    super.initState();
    final r = widget.registro;
    if (r != null) {
      _areaId = r.areaId;
      _localLivre.text = r.areaNome;
      _humor = r.humor;
      _atividades.addAll(r.atividades);
      _anotacao.text = r.anotacao ?? '';
    } else if (widget.area != null) {
      _areaId = widget.area!.id;
      _localLivre.text = widget.area!.nome;
    }
  }

  @override
  void dispose() {
    _anotacao.dispose();
    _localLivre.dispose();
    super.dispose();
  }

  Future<void> _escolherLocal() async {
    final areas = AreasEstado.instancia.areas;
    final escolhida = await showModalBottomSheet<AreaVerde>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (c) => ListView(children: [
        for (final a in areas)
          ListTile(
            title: Text(a.nome),
            subtitle: Text(a.bairro),
            onTap: () => Navigator.pop(c, a),
          ),
      ]),
    );
    if (escolhida != null) {
      setState(() {
        _areaId = escolhida.id;
        _localLivre.text = escolhida.nome;
      });
    }
  }

  Future<void> _salvar() async {
    // Regras do protótipo: humor obrigatório; local obrigatório
    // (area_nome é NOT NULL no SQLite), mas pode ser um lugar fora do app.
    if (_humor == null) {
      avisar(context, 'Escolha como você se sente para salvar.');
      return;
    }
    final nomeLocal = _localLivre.text.trim();
    if (nomeLocal.isEmpty) {
      avisar(context, 'Informe ou escolha o local visitado.');
      return;
    }
    await DiarioRepositorio.instancia.salvar(RegistroDiario(
      id: widget.registro?.id,
      areaId: _areaId,
      areaNome: nomeLocal,
      humor: _humor!,
      atividades: _atividades.toList(),
      anotacao: _anotacao.text.trim().isEmpty ? null : _anotacao.text.trim(),
      dataHora: _dataHora,
    ));
    if (!mounted) return;
    avisar(context, 'Registro salvo');
    final area = _areaId == null ? null : AreasEstado.instancia.porId(_areaId!);
    if (!_editando && area != null) {
      // Protótipo: "Quer avaliar o local? (público, opcional)".
      final avaliar = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Quer avaliar o local?'),
          content: const Text('A avaliação é pública e opcional. O diário continua privado.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Agora não')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Avaliar')),
          ],
        ),
      );
      if (!mounted) return;
      if (avaliar == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AvaliacaoTela(area: area)),
        );
        return;
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> _excluir() async {
    final ok = await confirmar(context, titulo: 'Excluir este registro?');
    if (!ok || !mounted) return;
    await DiarioRepositorio.instancia.excluir(widget.registro!.id!);
    if (!mounted) return;
    avisar(context, 'Registro excluído');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de bem-estar'),
        actions: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir registro',
              onPressed: _excluir,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Como você está depois da visita?', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _localLivre,
          onChanged: (_) => _areaId = null, // nome digitado = local fora do app
          decoration: InputDecoration(
            labelText: 'Local visitado',
            prefixIcon: const Icon(Icons.park_outlined),
            suffixIcon: IconButton(
              tooltip: 'Escolher da lista',
              icon: const Icon(Icons.list),
              onPressed: _escolherLocal,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(formatarDiaHora(_dataHora), style: tema.textTheme.bodyMedium),
        const SizedBox(height: 24),
        Text('Como você se sente agora?', style: tema.textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(children: [
          for (final h in Humor.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: _humor == h,
                label: h.rotulo,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _humor = h),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _humor == h ? Cores.folhaClara : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _humor == h ? Cores.floresta : const Color(0xFFD6DCD8),
                        width: _humor == h ? 2 : 1,
                      ),
                    ),
                    child: Column(children: [
                      Text(emojiHumor(h), style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(h.rotulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: Cores.texto)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 24),
        Text('O que você fez lá?', style: tema.textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in AtividadeRealizada.values)
            FilterChip(
              label: Text(a.rotulo),
              selected: _atividades.contains(a),
              onSelected: (s) =>
                  setState(() => s ? _atividades.add(a) : _atividades.remove(a)),
            ),
        ]),
        const SizedBox(height: 24),
        TextField(
          controller: _anotacao,
          maxLines: 3,
          maxLength: 300,
          decoration: const InputDecoration(labelText: 'Anotações (opcional)'),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _salvar, child: const Text('Salvar registro')),
        const SizedBox(height: 8),
        Text(
          'Fica só neste aparelho. Seu diário não é enviado para nenhum servidor '
          'e não precisa de login.',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodyMedium,
        ),
      ]),
    );
  }
}
