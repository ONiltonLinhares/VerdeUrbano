import 'package:flutter_test/flutter_test.dart';
import 'package:verde_urbano/core/formatos.dart';
import 'package:verde_urbano/core/validadores.dart';
import 'package:verde_urbano/models/area_verde.dart';

void main() {
  group('Textos exibidos nas telas', () {
    test('distância em metros e quilômetros', () {
      expect(formatarDistancia(650), '650 m');
      expect(formatarDistancia(2400), '2,4 km');
    });

    test('situação do horário no card do protótipo', () {
      const h = Horario(abreEm: 360, fechaEm: 1200);
      expect(situacaoHorario(h, DateTime(2026, 11, 12, 10)), 'Aberto até 20h');
      expect(situacaoHorario(h, DateTime(2026, 11, 12, 21)), 'Fechado agora');
      const h24 = Horario(abreEm: 0, fechaEm: 1440, vinteQuatroHoras: true);
      expect(situacaoHorario(h24, DateTime(2026, 11, 12, 3)), 'Aberto 24h');
    });

    test('descrição do horário na página do local', () {
      expect(descricaoHorario(const Horario(abreEm: 360, fechaEm: 1200)),
          'todos os dias, 6h às 20h');
    });

    test('tempo a pé estimado (Rota · 9 min a pé)', () {
      expect(minutosEstimados(650, 'a_pe'), 9);
      expect(minutosEstimados(650, 'bicicleta'), 3);
    });

    test('tempo relativo das avaliações', () {
      final agora = DateTime(2026, 11, 12, 12);
      expect(tempoRelativo(agora.subtract(const Duration(days: 3)), agora: agora),
          'há 3 dias');
      expect(tempoRelativo(agora.subtract(const Duration(days: 7)), agora: agora),
          'há 1 semana');
    });
  });

  group('Validações dos formulários', () {
    test('e-mail e senha', () {
      expect(Validadores.email('marina@email.com'), isNull);
      expect(Validadores.email('marina'), isNotNull);
      expect(Validadores.senha('123'), isNotNull);
    });

    test('nome com no máximo 60 caracteres (igual ao firestore.rules)', () {
      expect(Validadores.nome('Marina Alves'), isNull);
      expect(Validadores.nome('a' * 61), isNotNull);
    });

    test('horário HH:MM vira minutos desde a meia-noite', () {
      expect(Validadores.hora('06:00'), isNull);
      expect(Validadores.hora('25:00'), isNotNull);
      expect(Validadores.minutosDe('20:00'), 1200);
    });
  });
}
