import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/erros.dart';
import '../models/enums.dart';
import '../models/usuario.dart';

/// Sessão do usuário: Firebase Auth + perfil em `usuarios/{uid}` (CRUD 1).
///
/// O login é opcional (RNF03). Ele só é exigido para avaliar, enviar foto,
/// criar evento, sinalizar, favoritar e sugerir local.
class Sessao extends ChangeNotifier {
  Sessao._();
  static final instancia = Sessao._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  StreamSubscription<User?>? _subAuth;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subPerfil;

  bool _iniciada = false;
  Usuario? _perfil;

  /// Lido direto do Firebase Auth: logo depois do login o `currentUser` já
  /// está preenchido, mesmo antes de o stream de autenticação avisar.
  User? get user => _iniciada ? _auth.currentUser : null;
  String? get uid => user?.uid;
  Usuario? get perfil => _perfil;
  bool get logado => user != null;
  bool get isAdmin => _perfil?.isAdmin ?? false;

  /// Nome mostrado nas avaliações, fotos e eventos.
  String get nomePublico {
    final n = _perfil?.nome ?? user?.displayName ?? '';
    return n.trim().isEmpty ? 'Usuário' : n.trim();
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('usuarios').doc(uid);

  /// Chamado uma vez no main(), depois do Firebase.initializeApp.
  void iniciar() {
    _iniciada = true;
    _subAuth ??= _auth.authStateChanges().listen(_aoMudarUsuario);
  }

  void _aoMudarUsuario(User? u) {
    _subPerfil?.cancel();
    _subPerfil = null;
    _perfil = null;
    if (u != null) {
      _subPerfil = _doc(u.uid).snapshots().listen(
        (snap) {
          _perfil = snap.exists ? Usuario.fromFirestore(snap) : null;
          notifyListeners();
        },
        onError: (Object _) {}, // sem rede: mantém o último perfil
      );
    }
    notifyListeners();
  }

  Future<void> entrar(String email, String senha) async {
    try {
      await comLimiteDeTempo(
          _auth.signInWithEmailAndPassword(email: email.trim(), password: senha));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Cria a conta e o perfil. Regra: ninguém nasce admin (papel = usuario);
  /// o papel de admin é dado pelo console do Firebase.
  Future<void> cadastrar(String nome, String email, String senha) async {
    try {
      final cred = await comLimiteDeTempo(_auth
          .createUserWithEmailAndPassword(email: email.trim(), password: senha));
      final u = cred.user!;
      await u.updateDisplayName(nome.trim());
      final agora = DateTime.now();
      await comLimiteDeTempo(_doc(u.uid).set(Usuario(
        id: u.uid,
        nome: nome.trim(),
        email: email.trim(),
        papel: PapelUsuario.usuario,
        criadoEm: agora,
        atualizadoEm: agora,
      ).toFirestore()));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  Future<void> redefinirSenha(String email) async {
    try {
      await comLimiteDeTempo(_auth.sendPasswordResetEmail(email: email.trim()));
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  /// Atualiza nome e preferências. O campo `papel` nunca é enviado.
  Future<void> atualizarPerfil({
    required String nome,
    required List<Atividade> preferencias,
  }) async {
    final u = user;
    if (u == null) throw const ErroApp('Entre na sua conta primeiro.');
    try {
      final dados = <String, dynamic>{
        'nome': nome.trim(),
        'preferencias': preferencias.map((p) => p.name).toList(),
        'atualizadoEm': Timestamp.fromDate(DateTime.now()),
      };
      if (_perfil == null) {
        // Conta antiga sem documento de perfil: cria agora.
        final agora = DateTime.now();
        await comLimiteDeTempo(_doc(u.uid).set(Usuario(
          id: u.uid,
          nome: nome.trim(),
          email: u.email ?? '',
          preferencias: preferencias,
          criadoEm: agora,
          atualizadoEm: agora,
        ).toFirestore()));
      } else {
        await comLimiteDeTempo(_doc(u.uid).update(dados));
      }
      await u.updateDisplayName(nome.trim());
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  Future<void> sair() => _auth.signOut();

  /// Tempo máximo desde o último login para o Firebase aceitar apagar a conta.
  /// Passando disso ele recusa (`requires-recent-login`); a margem é de 1 min.
  static const _loginRecente = Duration(minutes: 4);

  /// Exclusão de conta (LGPD) — ordem descrita em modelagem-dados.md, 3.3:
  /// 1. busca avaliações, fotos e eventos do usuário (collection group);
  /// 2. avaliações e eventos ficam com "Usuário removido";
  /// 3. fotos são apagadas; 4. favoritos são apagados;
  /// 5. perfil é apagado; 6. conta do Firebase Auth é apagada.
  ///
  /// Antes de mexer em qualquer dado, confere se o Firebase vai aceitar apagar
  /// a conta no fim (login recente). Se [senhaAtual] vier preenchida, o
  /// usuário é autenticado de novo; sem ela, só vale quem entrou há pouco.
  /// Os passos 2 a 5 rodam em lotes de até [_tamanhoLote] operações (o
  /// Firestore aceita no máximo 500 por lote) e o perfil é o último a sair:
  /// se algo falhar no meio, dá para tentar de novo.
  Future<void> excluirConta({String? senhaAtual}) async {
    final u = user;
    if (u == null) return;
    const anonimo = 'Usuário removido';
    try {
      if (senhaAtual != null && (u.email ?? '').isNotEmpty) {
        await comLimiteDeTempo(u.reauthenticateWithCredential(
            EmailAuthProvider.credential(
                email: u.email!, password: senhaAtual)));
      } else {
        final login = (await comLimiteDeTempo(u.getIdTokenResult())).authTime;
        if (login == null || DateTime.now().difference(login) > _loginRecente) {
          throw FirebaseAuthException(code: 'requires-recent-login');
        }
      }

      final avaliacoes = await _db
          .collectionGroup('avaliacoes')
          .where('autorId', isEqualTo: u.uid)
          .get();
      final fotos = await _db
          .collectionGroup('fotos')
          .where('autorId', isEqualTo: u.uid)
          .get();
      final eventos = await _db
          .collectionGroup('eventos')
          .where('organizadorId', isEqualTo: u.uid)
          .get();
      final favoritos = await _doc(u.uid).collection('favoritos').get();

      final operacoes = <void Function(WriteBatch)>[
        for (final a in avaliacoes.docs)
          (b) => b.update(a.reference, {'autorNome': anonimo}),
        for (final e in eventos.docs)
          (b) => b.update(e.reference, {'organizadorNome': anonimo}),
        for (final f in fotos.docs) (b) => b.delete(f.reference),
        for (final f in favoritos.docs) (b) => b.delete(f.reference),
        (b) => b.delete(_doc(u.uid)), // por último
      ];
      for (var i = 0; i < operacoes.length; i += _tamanhoLote) {
        final lote = _db.batch();
        for (final op in operacoes.skip(i).take(_tamanhoLote)) {
          op(lote);
        }
        await comLimiteDeTempo(lote.commit(),
            limite: const Duration(seconds: 30));
      }
      await u.delete();
    } catch (e) {
      throw ErroApp(mensagemDeErro(e));
    }
  }

  static const _tamanhoLote = 400;

  @override
  void dispose() {
    _subAuth?.cancel();
    _subPerfil?.cancel();
    super.dispose();
  }
}
