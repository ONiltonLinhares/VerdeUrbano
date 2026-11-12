import 'package:material_ui/material_ui.dart';

/// Estrutura principal: barra inferior com as 4 abas do protótipo
/// (Início, Mapa, Salvos, Diário). IndexedStack mantém o estado de cada aba
/// ao trocar (ex.: posição do mapa não reseta).
///
/// TODO(sprint 2): substituir cada placeholder pela tela real.
class ShellTela extends StatefulWidget {
  const ShellTela({super.key});

  @override
  State<ShellTela> createState() => _ShellTelaState();
}

class _ShellTelaState extends State<ShellTela> {
  int _aba = 0;

  static const _abas = <Widget>[
    _Placeholder('Que tal um respiro verde hoje?'),
    _Placeholder('Mapa'),
    _Placeholder('Salvos'),
    _Placeholder('Diário de bem-estar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _aba, children: _abas)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Salvos'),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Diário'),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(titulo, style: Theme.of(context).textTheme.displaySmall),
    );
  }
}
