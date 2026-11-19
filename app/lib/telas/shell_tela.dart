import 'package:material_ui/material_ui.dart';

import '../estado/localizacao_estado.dart';
import '../widgets/componentes.dart';
import 'diario_tela.dart';
import 'inicio_tela.dart';
import 'mapa_tela.dart';
import 'salvos_tela.dart';

/// Estrutura principal: barra inferior com as 4 abas do protótipo
/// (Início, Mapa, Salvos, Diário). IndexedStack mantém o estado de cada aba
/// ao trocar (ex.: posição do mapa não reseta).
class ShellTela extends StatefulWidget {
  const ShellTela({super.key});

  @override
  State<ShellTela> createState() => _ShellTelaState();
}

class _ShellTelaState extends State<ShellTela> {
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    // Pede a localização depois que a tela aparece (distâncias, RF02).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!LocalizacaoEstado.instancia.temPosicao) {
        LocalizacaoEstado.instancia.atualizar();
      }
    });
  }

  void _irPara(int i) => setState(() => _aba = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          const FaixaOffline(),
          Expanded(
            child: IndexedStack(index: _aba, children: [
              InicioTela(aoVerMapa: () => _irPara(1)),
              const MapaTela(),
              const SalvosTela(),
              const DiarioTela(),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: _irPara,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início'),
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Mapa'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Salvos'),
          NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Diário'),
        ],
      ),
    );
  }
}
