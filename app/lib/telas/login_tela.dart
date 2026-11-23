import 'package:material_ui/material_ui.dart';

import '../core/navegacao.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../estado/sessao.dart';
import '../widgets/componentes.dart';
import 'cadastro_tela.dart';
import 'shell_tela.dart';

/// Tela de login (item e.i da Unidade II) — Firebase Auth com e-mail e senha.
/// RNF03: consultar o mapa não exige conta, por isso existe "Explorar sem conta".
/// O login só é exigido para favoritar, avaliar, enviar foto, criar evento,
/// sinalizar e sugerir local.
class LoginTela extends StatefulWidget {
  /// true quando aberta no meio de uma ação (ex.: "Salvar"): ao entrar,
  /// volta para onde o usuário estava. false quando é a tela inicial.
  const LoginTela({super.key, this.fecharAoEntrar = false});

  final bool fecharAoEntrar;

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultarSenha = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _seguir() {
    if (widget.fecharAoEntrar && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ShellTela()),
      );
    }
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await Sessao.instancia.entrar(_email.text, _senha.text);
      if (!mounted) return;
      avisar(context, 'Bem-vindo(a) de volta!');
      _seguir();
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _esqueciSenha() async {
    if (Validadores.email(_email.text) != null) {
      setState(() => _erro = 'Digite seu e-mail acima para redefinir a senha.');
      return;
    }
    try {
      await Sessao.instancia.redefinirSenha(_email.text);
      if (mounted) avisar(context, 'Enviamos um link de redefinição para seu e-mail.');
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    }
  }

  Future<void> _criarConta() async {
    final criou = await abrir<bool>(context, const CadastroTela());
    if (criou == true && mounted) _seguir();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: widget.fecharAoEntrar ? AppBar(backgroundColor: Cores.fundo) : null,
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.eco, size: 52, color: Cores.floresta),
              const SizedBox(height: 8),
              Text('VerdeUrbano', style: tema.textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'O guia que transforma a selva de pedra em um quintal verde.',
                style: tema.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: Validadores.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senha,
                obscureText: _ocultarSenha,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _entrar(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                    icon: Icon(_ocultarSenha ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                  ),
                ),
                validator: Validadores.senha,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _esqueciSenha,
                  child: const Text('Esqueci minha senha'),
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
                onPressed: _carregando ? null : _entrar,
                child: _carregando ? const GirandoNoBotao() : const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _carregando ? null : _criarConta,
                child: const Text('Criar conta'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (widget.fecharAoEntrar) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ShellTela()),
                    );
                  }
                },
                child: Text(widget.fecharAoEntrar ? 'Agora não' : 'Explorar sem conta'),
              ),
              Text(
                'Você pode usar o mapa e o diário sem criar conta.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
