import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:verde_urbano/models/enums.dart';
import 'package:verde_urbano/telas/login_tela.dart';
import 'package:verde_urbano/widgets/componentes.dart';

// Testes de widget sem Firebase e sem Google Fonts (usam o tema padrão).
void main() {
  testWidgets('Login valida e-mail e senha antes de chamar o Firebase', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginTela()));

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });

  testWidgets('Login aponta senha curta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginTela()));

    await tester.enterText(find.byType(TextFormField).at(0), 'marina@email.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('A senha precisa ter pelo menos 6 caracteres.'), findsOneWidget);
  });

  testWidgets('RF07: os três estados aparecem com texto, não só cor', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          LinhaDisponibilidade(
              icone: Icons.accessible, rotulo: 'Rampas', valor: Disponibilidade.tem),
          LinhaDisponibilidade(
              icone: Icons.wc, rotulo: 'Banheiro adaptado', valor: Disponibilidade.naoTem),
          LinhaDisponibilidade(
              icone: Icons.light_outlined,
              rotulo: 'Iluminação',
              valor: Disponibilidade.naoInformado),
        ]),
      ),
    ));

    expect(find.text('Tem'), findsOneWidget);
    expect(find.text('Não tem'), findsOneWidget);
    expect(find.text('Não informado'), findsOneWidget);
  });
}
