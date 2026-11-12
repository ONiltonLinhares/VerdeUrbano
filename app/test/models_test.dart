import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verde_urbano/models/area_verde.dart';
import 'package:verde_urbano/models/enums.dart';
import 'package:verde_urbano/models/registro_diario.dart';

void main() {
  group('AreaVerde.fromMap', () {
    test('recurso ausente vira "não informado" (RF07)', () {
      final area = AreaVerde.fromMap('x', {
        'nome': 'Praça do Ipê',
        'estrutura': {'bancos': 'tem', 'banheiros': 'naoTem'},
      });

      expect(area.estrutura[Recurso.bancos], Disponibilidade.tem);
      expect(area.estrutura[Recurso.banheiros], Disponibilidade.naoTem);
      expect(area.estrutura[Recurso.bebedouros], Disponibilidade.naoInformado);
      expect(area.acessibilidade[RecursoAcessibilidade.rampas],
          Disponibilidade.naoInformado);
    });

    test('valor desconhecido no banco não derruba o app', () {
      final area = AreaVerde.fromMap('x', {
        'tipo': 'shopping',
        'atividades': ['caminhada', 'skate'],
        'estrutura': {'bancos': 'talvez'},
      });

      expect(area.tipo, TipoArea.parque);
      expect(area.atividades, [Atividade.caminhada]);
      expect(area.estrutura[Recurso.bancos], Disponibilidade.naoInformado);
    });

    test('ida e volta Dart → Firestore → Dart preserva os dados', () {
      final original = AreaVerde.fromMap('parque-aguas-claras', {
        'nome': 'Parque das Águas Claras',
        'tipo': 'parque',
        'localizacao': const GeoPoint(-23.55, -46.63),
        'horario': {'abre': '06:00', 'fecha': '20:00', 'vinteQuatroHoras': false},
        'atividades': ['caminhada', 'corrida'],
        'acessibilidade': {'rampas': 'tem', 'caminhosAcessiveis': 'tem'},
        'status': 'publicada',
        'resumo': {'total': 2, 'somaNotas': 9.0},
        'atualizadoEm': Timestamp.fromDate(DateTime(2026, 9, 12)),
      });

      final copia = AreaVerde.fromMap(original.id, original.toFirestore());

      expect(copia.nome, original.nome);
      expect(copia.atividades, original.atividades);
      expect(copia.acessibilidade, original.acessibilidade);
      expect(copia.atualizadoEm, DateTime(2026, 9, 12));
      expect(copia.resumo.media, 4.5);
      expect(copia.isAcessivel, isTrue);
    });

    test('cópia offline em JSON volta igual', () {
      final original = AreaVerde.fromMap('a', {
        'nome': 'Bosque',
        'localizacao': const GeoPoint(-10.9, -37.0),
        'atualizadoEm': Timestamp.fromDate(DateTime(2026, 10, 1)),
      });

      final copia = AreaVerde.fromMap('a', original.toJsonOffline());

      expect(copia.localizacao.latitude, -10.9);
      expect(copia.atualizadoEm, DateTime(2026, 10, 1));
    });
  });

  group('Horario', () {
    const horario = Horario(abre: '06:00', fecha: '20:00', vinteQuatroHoras: false);

    test('aberto dentro do intervalo, fechado fora', () {
      expect(horario.estaAberto(DateTime(2026, 1, 1, 6, 0)), isTrue);
      expect(horario.estaAberto(DateTime(2026, 1, 1, 19, 59)), isTrue);
      expect(horario.estaAberto(DateTime(2026, 1, 1, 20, 0)), isFalse);
      expect(horario.estaAberto(DateTime(2026, 1, 1, 5, 59)), isFalse);
    });

    test('24h está sempre aberto', () {
      const h = Horario(abre: '', fecha: '', vinteQuatroHoras: true);
      expect(h.estaAberto(DateTime(2026, 1, 1, 3, 0)), isTrue);
    });
  });

  test('ResumoAvaliacoes sem avaliações tem média 0, sem divisão por zero', () {
    expect(const ResumoAvaliacoes().media, 0);
  });

  test('RegistroDiario ida e volta no SQLite', () {
    final registro = RegistroDiario(
      areaNome: 'Parque das Águas Claras',
      humor: Humor.calmo,
      atividades: [AtividadeRealizada.caminhei, AtividadeRealizada.observeiNatureza],
      dataHora: DateTime(2026, 11, 11, 17, 40),
    );

    final copia = RegistroDiario.fromSqlite(registro.toSqlite());

    expect(copia.humor, Humor.calmo);
    expect(copia.atividades, registro.atividades);
    expect(copia.dataHora, registro.dataHora);
  });
}
