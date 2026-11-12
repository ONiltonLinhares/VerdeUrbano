// ARQUIVO PROVISÓRIO.
//
// Será SUBSTITUÍDO automaticamente quando o grupo rodar, dentro da pasta app/:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Enquanto isso, o app compila e abre uma tela avisando que o Firebase
// ainda não foi configurado (ver main.dart).

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase ainda não configurado. Rode "flutterfire configure" na pasta app/.',
    );
  }
}
