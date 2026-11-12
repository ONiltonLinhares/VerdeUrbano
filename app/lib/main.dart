import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'core/tema.dart';
import 'firebase_options.dart';
import 'telas/firebase_pendente_tela.dart';
import 'telas/login_tela.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? erroFirebase;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Cache local do Firestore: o que já foi visto continua disponível sem
    // internet (RNF05). No Android/iOS já vem ligado; aqui fica explícito.
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  } catch (e) {
    erroFirebase = e;
  }

  runApp(VerdeUrbanoApp(erroFirebase: erroFirebase));
}

class VerdeUrbanoApp extends StatelessWidget {
  const VerdeUrbanoApp({super.key, this.erroFirebase});

  final Object? erroFirebase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VerdeUrbano',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      home: erroFirebase == null
          ? const LoginTela()
          : FirebasePendenteTela(erro: erroFirebase!),
    );
  }
}
