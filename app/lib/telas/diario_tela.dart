import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/tema.dart';
import '../data/diario_repositorio.dart';
import '../models/enums.dart';
import '../widgets/componentes.dart';
import 'registro_diario_tela.dart';

/// Rosto de cada humor (escala do protótipo).
String emojiHumor(Humor h) => switch (h) {
      Humor.agitado => '😣',
      Humor.cansado => '😮‍💨',
      Humor.neutro => '😐',
      Humor.calmo => '😌',
      Humor.revigorado => '😄',
    };

/// Aba Diário de bem-estar. Funciona sem login e sem internet;
/// os registros ficam só no aparelho, em SQLite (RNF04).
class DiarioTela extends StatelessWidget {
  const DiarioTela({super.key});

  @override
  Widget build(BuildContext context) {
    final diario = DiarioRepositorio.instancia;
    return ListenableBuilder(
      listenable: diario,
      builder: (context, _) {
        final tema = Theme.of(context);
        return Scaffold(
          backgroundColor: Cores.fundo,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'novo-registro',
            onPressed: () => abrir(context, const RegistroDiarioTela()),
            icon: const Icon(Icons.add),
            label: const Text('Novo registro'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            children: [
              Text('Diário de bem-estar', style: tema.textTheme.displaySmall),
              const SizedBox(height: 8),
              const _AvisoPrivado(),
              const SizedBox(height: 16),
              if (!diario.carregado)
                const Center(child: CircularProgressIndicator())
              else if (diario.registros.isEmpty)
                const EstadoVazio(
                  icone: Icons.spa_outlined,
                  titulo: 'Nenhum registro ainda',
                  mensagem: 'Depois de visitar uma área verde, registre como você se sentiu.',
                )
              else
                for (final r in diario.registros)
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Text(emojiHumor(r.humor),
                          style: const TextStyle(fontSize: 32),
                          semanticsLabel: r.humor.rotulo),
                      title: Text(r.areaNome,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: Cores.texto)),
                      subtitle: Text([
                        '${r.humor.rotulo} · ${formatarDiaHora(r.dataHora)}',
                        if (r.atividades.isNotEmpty)
                          r.atividades.map((a) => a.rotulo).join(', '),
                        if ((r.anotacao ?? '').isNotEmpty) '“${r.anotacao}”',
                      ].join('\n')),
                      onTap: () => abrir(context, RegistroDiarioTela(registro: r)),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _AvisoPrivado extends StatelessWidget {
  const _AvisoPrivado();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Cores.folhaClara, borderRadius: BorderRadius.circular(12)),
        child: const Row(children: [
          Icon(Icons.lock_outline, color: Cores.floresta),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fica só neste aparelho. Seu diário não é enviado para nenhum '
              'servidor e não precisa de login.',
              style: TextStyle(color: Cores.texto),
            ),
          ),
        ]),
      );
}
