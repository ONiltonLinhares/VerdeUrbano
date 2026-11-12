import 'package:material_ui/material_ui.dart';

import 'shell_tela.dart';

/// Tela de login (item e.i da Unidade II).
/// RNF03: consultar o mapa não exige conta, por isso existe "Explorar sem conta".
/// O login só é exigido para favoritar, avaliar e sinalizar.
///
/// TODO(sprint 2): integrar com FirebaseAuth (entrar, cadastrar, recuperar senha).
class LoginTela extends StatelessWidget {
  const LoginTela({super.key});

  void _entrarNoApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ShellTela()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('VerdeUrbano', style: tema.textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'O guia que transforma a selva de pedra em um quintal verde.',
                style: tema.textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _entrarNoApp(context),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _entrarNoApp(context),
                child: const Text('Explorar sem conta'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
