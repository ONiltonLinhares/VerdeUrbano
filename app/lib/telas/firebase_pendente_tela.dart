import 'package:material_ui/material_ui.dart';

/// Mostrada só enquanto o Firebase não foi configurado. Evita que o app feche
/// sozinho ao abrir (o que zeraria a avaliação: "app que não executa").
class FirebasePendenteTela extends StatelessWidget {
  const FirebasePendenteTela({super.key, required this.erro});

  final Object erro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Firebase não configurado',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              const Text('Na pasta app/, rode:\n\nflutterfire configure'),
              const SizedBox(height: 16),
              Text('$erro', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
