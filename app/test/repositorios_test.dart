import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verde_urbano/core/erros.dart';
import 'package:verde_urbano/data/avaliacoes_repositorio.dart';
import 'package:verde_urbano/data/eventos_repositorio.dart';
import 'package:verde_urbano/data/fotos_repositorio.dart';
import 'package:verde_urbano/models/avaliacao.dart';
import 'package:verde_urbano/models/enums.dart';
import 'package:verde_urbano/models/evento.dart';
import 'package:verde_urbano/models/foto.dart';

/// Regras de negócio da camada de chamadas que rodam no cliente, antes de
/// qualquer ida ao Firestore (as mesmas do firestore.rules).

Avaliacao _avaliacao({
  int nota = 4,
  int limpeza = 4,
  int conservacao = 3,
  int acessibilidade = 2,
  String comentario = '',
  String autorNome = 'Marina',
}) =>
    Avaliacao(
      id: 'u1',
      areaId: 'a',
      autorId: 'u1',
      autorNome: autorNome,
      nota: nota,
      notaLimpeza: limpeza,
      notaConservacao: conservacao,
      notaAcessibilidade: acessibilidade,
      comentario: comentario,
      criadoEm: DateTime(2026),
      atualizadoEm: DateTime(2026),
    );

Evento _evento({
  String titulo = 'Ioga ao amanhecer',
  String descricao = '',
  required DateTime inicio,
  required DateTime fim,
}) =>
    Evento(
      id: 'e1',
      areaId: 'a',
      titulo: titulo,
      descricao: descricao,
      tipo: TipoEvento.ioga,
      inicio: inicio,
      fim: fim,
      organizadorId: 'u1',
      organizadorNome: 'Marina',
    );

Matcher get _lancaErroApp => throwsA(isA<ErroApp>());

void main() {
  group('AvaliacoesRepositorio.validar', () {
    test('aceita notas de 1 a 5 e comentário de até 500 caracteres', () {
      expect(
          () => AvaliacoesRepositorio.validar(_avaliacao(
              nota: 1,
              limpeza: 5,
              comentario: 'a' * 500)),
          returnsNormally);
    });

    test('recusa nota fora de 1 a 5 em qualquer critério', () {
      for (final invalida in [0, 6, -1]) {
        expect(() => AvaliacoesRepositorio.validar(_avaliacao(nota: invalida)),
            _lancaErroApp);
        expect(
            () => AvaliacoesRepositorio.validar(_avaliacao(limpeza: invalida)),
            _lancaErroApp);
        expect(
            () => AvaliacoesRepositorio.validar(
                _avaliacao(conservacao: invalida)),
            _lancaErroApp);
        expect(
            () => AvaliacoesRepositorio.validar(
                _avaliacao(acessibilidade: invalida)),
            _lancaErroApp);
      }
    });

    test('recusa comentário com mais de 500 caracteres', () {
      expect(
          () => AvaliacoesRepositorio.validar(
              _avaliacao(comentario: 'a' * 501)),
          _lancaErroApp);
    });

    test('recusa nome do autor vazio ou com mais de 60 caracteres', () {
      expect(() => AvaliacoesRepositorio.validar(_avaliacao(autorNome: '')),
          _lancaErroApp);
      expect(
          () => AvaliacoesRepositorio.validar(
              _avaliacao(autorNome: 'a' * 61)),
          _lancaErroApp);
    });
  });

  group('FotosRepositorio.validar', () {
    test('aceita foto dentro do limite e legenda de até 200 caracteres', () {
      expect(
          () => FotosRepositorio.validar(
              Uint8List(Foto.tamanhoMaximoBytes), 'a' * 200),
          returnsNormally);
    });

    test('recusa foto vazia', () {
      expect(() => FotosRepositorio.validar(Uint8List(0), ''), _lancaErroApp);
    });

    test('recusa foto acima do tamanho máximo', () {
      expect(
          () => FotosRepositorio.validar(
              Uint8List(Foto.tamanhoMaximoBytes + 1), ''),
          _lancaErroApp);
    });

    test('recusa legenda com mais de 200 caracteres', () {
      expect(() => FotosRepositorio.validar(Uint8List(10), 'a' * 201),
          _lancaErroApp);
    });
  });

  group('EventosRepositorio.validar', () {
    final amanha = DateTime.now().add(const Duration(days: 1));
    final depois = amanha.add(const Duration(hours: 2));

    test('aceita evento futuro com período válido', () {
      expect(
          () => EventosRepositorio.validar(
              _evento(inicio: amanha, fim: depois),
              novo: true),
          returnsNormally);
    });

    test('recusa título vazio, só com espaços ou com mais de 80 caracteres',
        () {
      for (final titulo in ['', '   ', 'a' * 81]) {
        expect(
            () => EventosRepositorio.validar(
                _evento(titulo: titulo, inicio: amanha, fim: depois),
                novo: true),
            _lancaErroApp);
      }
    });

    test('recusa descrição com mais de 1000 caracteres', () {
      expect(
          () => EventosRepositorio.validar(
              _evento(descricao: 'a' * 1001, inicio: amanha, fim: depois),
              novo: true),
          _lancaErroApp);
    });

    test('recusa evento que termina antes (ou junto) de começar', () {
      expect(
          () => EventosRepositorio.validar(
              _evento(inicio: depois, fim: amanha),
              novo: true),
          _lancaErroApp);
      expect(
          () => EventosRepositorio.validar(
              _evento(inicio: amanha, fim: amanha),
              novo: true),
          _lancaErroApp);
    });

    test('só exige data futura na criação, não na edição', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      final evento = _evento(
          inicio: ontem, fim: ontem.add(const Duration(hours: 2)));
      expect(() => EventosRepositorio.validar(evento, novo: true),
          _lancaErroApp);
      expect(() => EventosRepositorio.validar(evento), returnsNormally);
    });
  });

  group('erros.dart', () {
    test('ErroApp passa a própria mensagem', () {
      expect(mensagemDeErro(const ErroApp('oi')), 'oi');
    });

    test('timeout vira mensagem de falta de conexão', () {
      expect(mensagemDeErro(TimeoutException('x')), contains('Sem conexão'));
    });

    test('permission-denied do Firestore vira mensagem de permissão', () {
      final erro =
          FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
      expect(mensagemDeErro(erro), contains('permissão'));
    });

    test('comLimiteDeTempo falha com ErroApp quando a operação não termina',
        () {
      expect(
          comLimiteDeTempo(Completer<void>().future,
              limite: const Duration(milliseconds: 20)),
          _lancaErroApp);
    });

    test('comLimiteDeTempo devolve o resultado quando a operação termina', () {
      expect(comLimiteDeTempo(Future.value(7)), completion(7));
    });
  });
}
