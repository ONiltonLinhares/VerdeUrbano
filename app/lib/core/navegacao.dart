import 'package:material_ui/material_ui.dart';

import '../estado/sessao.dart';
import '../telas/local_tela.dart';
import '../telas/login_tela.dart';

/// Atalhos de navegação usados por várias telas.
/// O fluxo completo está em docs/fluxo-navegacao.md.

Future<T?> abrir<T>(BuildContext context, Widget tela) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => tela));

/// Página do local (2º toque da jornada "abrir → tocar no parque → Rota").
Future<void> abrirLocal(BuildContext context, String areaId) =>
    abrir(context, LocalTela(areaId: areaId));

/// Ações que exigem conta (avaliar, foto, evento, sinalizar, favoritar,
/// sugerir local). Abre o login e devolve true se o usuário ficou logado.
Future<bool> garantirLogin(BuildContext context, {required String motivo}) async {
  final sessao = Sessao.instancia;
  if (sessao.logado) return true;
  avisar(context, motivo);
  await abrir(context, const LoginTela(fecharAoEntrar: true));
  return sessao.logado;
}

/// Mensagem rápida no rodapé ("Salvo offline", erros etc.).
void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
    ));
}

/// Confirmação para ações destrutivas (excluir avaliação, foto, conta…).
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  String? mensagem,
  String acao = 'Excluir',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(titulo),
      content: mensagem == null ? null : Text(mensagem),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(c).colorScheme.error),
          onPressed: () => Navigator.pop(c, true),
          child: Text(acao),
        ),
      ],
    ),
  );
  return ok ?? false;
}
