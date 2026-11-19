// Configuração do Firebase do projeto verdeurbano-9a251.
// Equivale ao arquivo gerado por `flutterfire configure`.
// As chaves abaixo são identificadores públicos do app (não são segredos);
// a proteção dos dados é feita pelas regras em firestore.rules.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase não configurado para $defaultTargetPlatform. '
          'Rode `flutterfire configure` para adicionar esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBB2F7aoQBTQ1fPqP5bwlxDHAQPck5FdSM',
    appId: '1:679727044557:web:bde09498baca73b8d71684',
    messagingSenderId: '679727044557',
    projectId: 'verdeurbano-9a251',
    authDomain: 'verdeurbano-9a251.firebaseapp.com',
    storageBucket: 'verdeurbano-9a251.firebasestorage.app',
    measurementId: 'G-SP5WVPTE2K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBB2F7aoQBTQ1fPqP5bwlxDHAQPck5FdSM',
    appId: '1:679727044557:android:e5fd9c66efe7820ad71684',
    messagingSenderId: '679727044557',
    projectId: 'verdeurbano-9a251',
    storageBucket: 'verdeurbano-9a251.firebasestorage.app',
  );
}
