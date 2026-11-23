import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../core/navegacao.dart';
import '../core/validadores.dart';
import '../data/areas_repositorio.dart';
import '../estado/localizacao_estado.dart';
import '../estado/sessao.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import '../widgets/componentes.dart';

/// Cadastro e edição de área verde (CRUD 2).
/// - Admin: cadastra já publicada e edita qualquer local.
/// - Morador logado: sugere um local, que entra como `pendente` e só
///   aparece para todos depois da aprovação do admin.
class AreaFormTela extends StatefulWidget {
  const AreaFormTela({super.key, this.area});
  final AreaVerde? area;

  @override
  State<AreaFormTela> createState() => _AreaFormTelaState();
}

class _AreaFormTelaState extends State<AreaFormTela> {
  final _form = GlobalKey<FormState>();
  late final AreaVerde? _a = widget.area;
  late final _nome = TextEditingController(text: _a?.nome);
  late final _endereco = TextEditingController(text: _a?.endereco);
  late final _bairro = TextEditingController(text: _a?.bairro);
  late final _cidade = TextEditingController(text: _a?.cidade);
  late final _lat = TextEditingController(text: _a?.localizacao.latitude.toString());
  late final _lng = TextEditingController(text: _a?.localizacao.longitude.toString());
  late final _abre = TextEditingController(
      text: Horario.formatar(_a?.horario.abreEm ?? 360));
  late final _fecha = TextEditingController(
      text: Horario.formatar(_a?.horario.fechaEm ?? 1200));
  late final _fonte = TextEditingController(text: _a?.fonte);
  late final _fotos = TextEditingController(text: _a?.fotos.join('\n'));

  late TipoArea _tipo = _a?.tipo ?? TipoArea.parque;
  late bool _aberto24h = _a?.horario.vinteQuatroHoras ?? false;
  late final Set<int> _dias = {...(_a?.horario.diasAbertos ?? Horario.todosOsDias)};
  late final Set<Atividade> _atividades = {...?_a?.atividades};
  late final Map<Recurso, Disponibilidade> _estrutura = {
    for (final r in Recurso.values)
      r: _a?.estrutura[r] ?? Disponibilidade.naoInformado,
  };
  late final Map<RecursoAcessibilidade, Disponibilidade> _acess = {
    for (final r in RecursoAcessibilidade.values)
      r: _a?.acessibilidade[r] ?? Disponibilidade.naoInformado,
  };
  bool _salvando = false;

  bool get _editando => _a != null;
  bool get _admin => Sessao.instancia.isAdmin;

  @override
  void dispose() {
    for (final c in [
      _nome, _endereco, _bairro, _cidade, _lat, _lng, _abre, _fecha, _fonte, _fotos,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) => double.parse(c.text.trim().replaceAll(',', '.'));

  Future<void> _usarMinhaLocalizacao() async {
    final loc = LocalizacaoEstado.instancia;
    await loc.atualizar();
    final p = loc.posicao;
    if (p == null) {
      if (mounted) avisar(context, 'Não foi possível obter sua localização.');
      return;
    }
    setState(() {
      _lat.text = p.latitude.toStringAsFixed(6);
      _lng.text = p.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (_atividades.isEmpty) {
      avisar(context, 'Selecione pelo menos uma atividade.');
      return;
    }
    if (_dias.isEmpty) {
      avisar(context, 'Selecione pelo menos um dia de funcionamento.');
      return;
    }
    final horario = Horario(
      abreEm: _aberto24h ? 0 : Validadores.minutosDe(_abre.text),
      fechaEm: _aberto24h ? 1440 : Validadores.minutosDe(_fecha.text),
      vinteQuatroHoras: _aberto24h,
      diasAbertos: _dias.toList()..sort(),
    );
    if (!horario.valido) {
      avisar(context, 'O horário de fechamento precisa ser depois da abertura.');
      return;
    }
    final sessao = Sessao.instancia;
    final area = AreaVerde(
      id: _a?.id ?? '',
      nome: _nome.text.trim(),
      tipo: _tipo,
      endereco: _endereco.text.trim(),
      bairro: _bairro.text.trim(),
      cidade: _cidade.text.trim(),
      localizacao: GeoPoint(_num(_lat), _num(_lng)),
      fotos: _fotos.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.startsWith('https://'))
          .toList(),
      horario: horario,
      atividades: _atividades.toList(),
      estrutura: _estrutura,
      acessibilidade: _acess,
      fonte: _fonte.text.trim().isEmpty
          ? (_admin ? 'Equipe VerdeUrbano' : 'Sugestão da comunidade')
          : _fonte.text.trim(),
      atualizadoEm: DateTime.now(), // RF08: data sempre renovada ao salvar
      // Regra: morador só cria como pendente; admin publica direto.
      status: _a?.status ?? (_admin ? StatusArea.publicada : StatusArea.pendente),
      resumo: _a?.resumo ?? const ResumoAvaliacoes(),
      criadoPor: _a?.criadoPor ?? (_admin ? null : sessao.uid),
    );
    setState(() => _salvando = true);
    try {
      if (_editando) {
        await AreasRepositorio.instancia.atualizar(area);
      } else {
        await AreasRepositorio.instancia.criar(area);
      }
      if (!mounted) return;
      avisar(
        context,
        _editando
            ? 'Local atualizado'
            : _admin
                ? 'Local cadastrado'
                : 'Sugestão enviada! Ela aparece para todos depois da revisão.',
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _campo(TextEditingController c, String rotulo,
      {String? Function(String?)? validar, TextInputType? teclado, int linhas = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: teclado,
        maxLines: linhas,
        decoration: InputDecoration(labelText: rotulo),
        validator: validar,
      ),
    );
  }

  Widget _seletor<T>(String rotulo, T chave, Map<T, Disponibilidade> mapa) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rotulo),
          const SizedBox(height: 4),
          SegmentedButton<Disponibilidade>(
            segments: const [
              ButtonSegment(value: Disponibilidade.tem, label: Text('Tem')),
              ButtonSegment(value: Disponibilidade.naoTem, label: Text('Não tem')),
              ButtonSegment(value: Disponibilidade.naoInformado, label: Text('Não sei')),
            ],
            selected: {mapa[chave]!},
            onSelectionChanged: (s) => setState(() => mapa[chave] = s.first),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final numero = const TextInputType.numberWithOptions(decimal: true, signed: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando
            ? 'Editar área verde'
            : _admin
                ? 'Nova área verde'
                : 'Sugerir local'),
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          if (!_admin && !_editando)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Sua sugestão será revisada antes de aparecer no mapa. '
                'Se não souber alguma informação, deixe "Não sei".',
                style: tema.textTheme.bodyMedium,
              ),
            ),
          _campo(_nome, 'Nome do local',
              validar: (v) => Validadores.obrigatorio(v, campo: 'Nome')),
          Wrap(spacing: 8, children: [
            for (final t in TipoArea.values)
              ChoiceChip(
                avatar: Icon(iconeTipo(t), size: 18),
                label: Text(t.rotulo),
                selected: _tipo == t,
                onSelected: (_) => setState(() => _tipo = t),
              ),
          ]),
          const SizedBox(height: 12),
          _campo(_endereco, 'Endereço',
              validar: (v) => Validadores.obrigatorio(v, campo: 'Endereço')),
          _campo(_bairro, 'Bairro',
              validar: (v) => Validadores.obrigatorio(v, campo: 'Bairro')),
          _campo(_cidade, 'Cidade',
              validar: (v) => Validadores.obrigatorio(v, campo: 'Cidade')),
          Row(children: [
            Expanded(
              child: _campo(_lat, 'Latitude',
                  teclado: numero,
                  validar: (v) =>
                      Validadores.numero(v, min: -90, max: 90, campo: 'Latitude')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(_lng, 'Longitude',
                  teclado: numero,
                  validar: (v) =>
                      Validadores.numero(v, min: -180, max: 180, campo: 'Longitude')),
            ),
          ]),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _usarMinhaLocalizacao,
              icon: const Icon(Icons.my_location),
              label: const Text('Estou no local: usar minha localização'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Funcionamento', style: tema.textTheme.titleLarge),
          Wrap(spacing: 6, children: [
            for (var d = 1; d <= 7; d++)
              FilterChip(
                label: Text(dias[d - 1]),
                selected: _dias.contains(d),
                onSelected: (s) => setState(() => s ? _dias.add(d) : _dias.remove(d)),
              ),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aberto 24 horas'),
            value: _aberto24h,
            onChanged: (v) => setState(() => _aberto24h = v),
          ),
          if (!_aberto24h)
            Row(children: [
              Expanded(child: _campo(_abre, 'Abre (HH:MM)', validar: Validadores.hora)),
              const SizedBox(width: 12),
              Expanded(child: _campo(_fecha, 'Fecha (HH:MM)', validar: Validadores.hora)),
            ]),
          Text('Atividades', style: tema.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in Atividade.values)
              FilterChip(
                avatar: Icon(iconeAtividade(a), size: 18),
                label: Text(a.rotulo),
                selected: _atividades.contains(a),
                onSelected: (s) =>
                    setState(() => s ? _atividades.add(a) : _atividades.remove(a)),
              ),
          ]),
          const SizedBox(height: 20),
          Text('Estrutura', style: tema.textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final r in Recurso.values) _seletor(r.rotulo, r, _estrutura),
          const SizedBox(height: 12),
          Text('Acessibilidade', style: tema.textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final r in RecursoAcessibilidade.values) _seletor(r.rotulo, r, _acess),
          const SizedBox(height: 12),
          if (_admin) ...[
            _campo(_fonte, 'Fonte da informação (RF08)'),
            _campo(_fotos, 'URLs das fotos oficiais (uma por linha, https://)', linhas: 3),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const GirandoNoBotao()
                : Text(_editando
                    ? 'Salvar alterações'
                    : _admin
                        ? 'Cadastrar'
                        : 'Enviar sugestão'),
          ),
        ]),
      ),
    );
  }
}
