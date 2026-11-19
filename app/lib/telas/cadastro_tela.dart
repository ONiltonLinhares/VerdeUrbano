import 'package:material_ui/material_ui.dart';

import '../core/navegacao.dart';
import '../core/validadores.dart';
import '../estado/sessao.dart';
import '../widgets/componentes.dart';

/// Cadastro de usuário (CRUD 1 — criar). Devolve true se a conta foi criada.
class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();
  bool _aceite = false;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    for (final c in [_nome, _email, _senha, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;
    if (!_aceite) {
      setState(() => _erro = 'É preciso concordar com os termos de privacidade.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await Sessao.instancia.cadastrar(_nome.text, _email.text, _senha.text);
      if (!mounted) return;
      avisar(context, 'Conta criada! Bem-vindo(a) ao VerdeUrbano.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(24), children: [
          Text(
            'Com uma conta você avalia locais, envia fotos, cria eventos, '
            'sinaliza informações e guarda seus favoritos em qualquer aparelho.',
            style: tema.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nome,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Nome (aparece nas suas avaliações)',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: Validadores.nome,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: Validadores.email,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _senha,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha (mín. 6 caracteres)',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: Validadores.senha,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmar,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar senha',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) => v != _senha.text ? 'As senhas não conferem.' : null,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _aceite,
            onChanged: (v) => setState(() => _aceite = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Concordo que meu nome apareça no que eu publicar. Minha '
              'localização e meu diário não são enviados ao servidor.',
            ),
          ),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_erro!,
                  style: TextStyle(
                      color: tema.colorScheme.error, fontWeight: FontWeight.w700)),
            ),
          FilledButton(
            onPressed: _carregando ? null : _cadastrar,
            child: _carregando ? const GirandoNoBotao() : const Text('Criar conta'),
          ),
        ]),
      ),
    );
  }
}
