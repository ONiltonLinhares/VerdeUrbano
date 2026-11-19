import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

/// Erro com mensagem pronta para mostrar ao usuário.
class ErroApp implements Exception {
  const ErroApp(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Traduz qualquer erro (rede, Firebase Auth, Firestore) para uma frase em
/// português. Centraliza o tratamento de falhas de conexão (item a.iv).
String mensagemDeErro(Object erro) {
  if (erro is ErroApp) return erro.mensagem;
  if (erro is SocketException || erro is TimeoutException) {
    return 'Sem conexão com a internet. Verifique sua rede e tente de novo.';
  }
  if (erro is FirebaseAuthException) return _erroAuth(erro.code);
  if (erro is FirebaseException) {
    switch (erro.code) {
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Serviço indisponível no momento. Verifique sua conexão.';
      case 'permission-denied':
        return 'Você não tem permissão para fazer isso.';
      case 'not-found':
        return 'Registro não encontrado. Ele pode ter sido removido.';
      case 'failed-precondition':
        return 'O banco ainda não está pronto para esta consulta (índice em criação). Tente em alguns minutos.';
      default:
        return 'Algo deu errado (${erro.code}). Tente novamente.';
    }
  }
  return 'Algo deu errado. Tente novamente.';
}

String _erroAuth(String codigo) {
  switch (codigo) {
    case 'invalid-email':
      return 'E-mail inválido.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'email-already-in-use':
      return 'Já existe uma conta com este e-mail.';
    case 'weak-password':
      return 'Senha fraca. Use pelo menos 6 caracteres.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
    case 'network-request-failed':
      return 'Sem conexão com a internet. Verifique sua rede e tente de novo.';
    case 'requires-recent-login':
      return 'Por segurança, saia e entre de novo antes de excluir a conta.';
    default:
      return 'Não foi possível autenticar ($codigo).';
  }
}

/// Limita o tempo de uma operação remota: sem isso, uma rede que cai no meio
/// da requisição deixa o botão girando para sempre.
Future<T> comLimiteDeTempo<T>(Future<T> operacao,
    {Duration limite = const Duration(seconds: 15)}) {
  return operacao.timeout(limite,
      onTimeout: () => throw const ErroApp(
          'A conexão demorou demais. Verifique sua internet e tente de novo.'));
}
