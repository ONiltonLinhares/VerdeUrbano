import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/validadores.dart';
import '../data/eventos_repositorio.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import '../models/evento.dart';
import '../widgets/componentes.dart';

/// Criar, editar, cancelar e excluir evento ou mutirão (CRUD 5).
/// Regras: só no futuro, fim depois do início, só o organizador edita.
class EventoTela extends StatefulWidget {
  const EventoTela({super.key, required this.area, this.evento});
  final AreaVerde area;
  final Evento? evento;

  @override
  State<EventoTela> createState() => _EventoTelaState();
}

class _EventoTelaState extends State<EventoTela> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.evento?.titulo);
  late final _descricao = TextEditingController(text: widget.evento?.descricao);
  late TipoEvento _tipo = widget.evento?.tipo ?? TipoEvento.ioga;
  late DateTime _inicio = widget.evento?.inicio ??
      DateTime.now().add(const Duration(days: 1)).copyWith(
          hour: 8, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  late DateTime _fim = widget.evento?.fim ?? _inicio.add(const Duration(hours: 1));
  bool _salvando = false;

  bool get _novo => widget.evento == null;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _inicio.isBefore(hoje) ? hoje : _inicio,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: hoje.add(const Duration(days: 365)),
    );
    if (d == null) return;
    final duracao = _fim.difference(_inicio);
    setState(() {
      _inicio = DateTime(d.year, d.month, d.day, _inicio.hour, _inicio.minute);
      _fim = _inicio.add(duracao);
    });
  }

  Future<void> _escolherHora({required bool inicio}) async {
    final atual = inicio ? _inicio : _fim;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: atual.hour, minute: atual.minute),
    );
    if (t == null) return;
    setState(() {
      final nova = DateTime(_inicio.year, _inicio.month, _inicio.day, t.hour, t.minute);
      if (inicio) {
        final duracao = _fim.difference(_inicio);
        _inicio = nova;
        _fim = nova.add(duracao);
      } else {
        _fim = nova;
      }
    });
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final sessao = Sessao.instancia;
    final evento = Evento(
      id: widget.evento?.id ?? '',
      areaId: widget.area.id,
      titulo: _titulo.text.trim(),
      descricao: _descricao.text.trim(),
      tipo: _tipo,
      inicio: _inicio,
      fim: _fim,
      organizadorId: widget.evento?.organizadorId ?? sessao.uid!,
      organizadorNome: widget.evento?.organizadorNome ?? sessao.nomePublico,
      status: widget.evento?.status ?? StatusEvento.agendado,
    );
    setState(() => _salvando = true);
    try {
      if (_novo) {
        await EventosRepositorio.instancia.criar(evento);
      } else {
        await EventosRepositorio.instancia.atualizar(evento);
      }
      if (!mounted) return;
      avisar(context, _novo ? 'Evento criado' : 'Evento atualizado');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _cancelar() async {
    final ok = await confirmar(context,
        titulo: 'Cancelar o evento?',
        mensagem: 'Ele continua aparecendo como cancelado, para avisar quem ia.',
        acao: 'Cancelar evento');
    if (!ok || !mounted) return;
    try {
      await EventosRepositorio.instancia.cancelar(widget.evento!);
      if (!mounted) return;
      avisar(context, 'Evento cancelado');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  Future<void> _excluir() async {
    final ok = await confirmar(context, titulo: 'Excluir o evento?');
    if (!ok || !mounted) return;
    try {
      await EventosRepositorio.instancia.excluir(widget.evento!);
      if (!mounted) return;
      avisar(context, 'Evento excluído');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cancelado = widget.evento?.status == StatusEvento.cancelado;
    return Scaffold(
      appBar: AppBar(
        title: Text(_novo ? 'Novo evento' : 'Editar evento'),
        actions: [
          if (!_novo)
            IconButton(
              tooltip: 'Excluir evento',
              onPressed: _excluir,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(widget.area.nome, style: tema.textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titulo,
            maxLength: 80,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: (v) => Validadores.texto(v, min: 1, max: 80, campo: 'Título'),
          ),
          Text('Tipo', style: tema.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in TipoEvento.values)
              ChoiceChip(
                label: Text(t.rotulo),
                selected: _tipo == t,
                onSelected: (_) => setState(() => _tipo = t),
              ),
          ]),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Data'),
            subtitle: Text(formatarData(_inicio)),
            onTap: _escolherData,
          ),
          Row(children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: const Text('Início'),
                subtitle: Text('${doisDigitos(_inicio.hour)}:${doisDigitos(_inicio.minute)}'),
                onTap: () => _escolherHora(inicio: true),
              ),
            ),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('Fim'),
                subtitle: Text('${doisDigitos(_fim.hour)}:${doisDigitos(_fim.minute)}'),
                onTap: () => _escolherHora(inicio: false),
              ),
            ),
          ]),
          if (!_fim.isAfter(_inicio))
            Text('O fim precisa ser depois do início.',
                style: TextStyle(color: tema.colorScheme.error)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descricao,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Ex.: traga sua canga e água.',
            ),
            validator: (v) => Validadores.texto(v, max: 1000),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _salvando || cancelado ? null : _salvar,
            child: _salvando
                ? const GirandoNoBotao()
                : Text(_novo ? 'Criar evento' : 'Salvar alterações'),
          ),
          if (!_novo && !cancelado) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _cancelar, child: const Text('Cancelar evento')),
          ],
        ]),
      ),
    );
  }
}
