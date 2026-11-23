import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'core/tema.dart';
import 'data/diario_repositorio.dart';
import 'data/offline_repositorio.dart';
import 'estado/areas_estado.dart';
import 'estado/conectividade_estado.dart';
import 'estado/sessao.dart';
import 'firebase_options.dart';
import 'telas/firebase_pendente_tela.dart';
import 'telas/login_tela.dart';
import 'telas/shell_tela.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dados locais (diário e cópias offline) não dependem do Firebase.
  // Uma falha aqui não pode impedir o app de abrir.
  try {
    await Future.wait([
      DiarioRepositorio.instancia.carregar(),
      OfflineRepositorio.instancia.carregar(),
      ConectividadeEstado.instancia.iniciar(),
    ]);
  } catch (_) {}

  Object? erroFirebase;
  var logado = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Cache local do Firestore: o que já foi visto continua disponível sem
    // internet (RNF05). No Android/iOS já vem ligado; aqui fica explícito.
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    logado = FirebaseAuth.instance.currentUser != null;
    Sessao.instancia.iniciar();
    AreasEstado.instancia.iniciar();
  } catch (e) {
    erroFirebase = e;
  }

  runApp(VerdeUrbanoApp(erroFirebase: erroFirebase, logado: logado));
}

class VerdeUrbanoApp extends StatelessWidget {
  const VerdeUrbanoApp({super.key, this.erroFirebase, this.logado = false});

  final Object? erroFirebase;

  /// Quem já entrou vai direto para o Início (RNF01: rota em 3 toques);
  /// quem não entrou vê o login, com a opção "Explorar sem conta" (RNF03).
  final bool logado;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VerdeUrbano',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Pacotes que ainda usam package:flutter/material.dart (ex.: flutter_map)
      // encontram o tema e as traduções através desta ponte.
      builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
      home: erroFirebase != null
          ? FirebasePendenteTela(erro: erroFirebase!)
          : logado
              ? const ShellTela()
              : const LoginTela(),
    );
  }
}
