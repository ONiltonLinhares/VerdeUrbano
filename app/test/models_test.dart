import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verde_urbano/models/area_verde.dart';
import 'package:verde_urbano/models/avaliacao.dart';
import 'package:verde_urbano/models/enums.dart';
import 'package:verde_urbano/models/evento.dart';
import 'package:verde_urbano/models/registro_diario.dart';

Avaliacao _avaliacao(int nota, {int limpeza = 4}) => Avaliacao(
      id: 'u1',
      areaId: 'a',
      autorId: 'u1',
      autorNome: 'Marina',
      nota: nota,
      notaLimpeza: limpeza,
      notaConservacao: 3,
      notaAcessibilidade: 2,
      comentario: '',
      criadoEm: DateTime(2026),
      atualizadoEm: DateTime(2026),
    );

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
        'horario': {'abreEm': 360, 'fechaEm': 1200, 'vinteQuatroHoras': false},
        'atividades': ['caminhada', 'corrida'],
        'acessibilidade': {'rampas': 'tem', 'caminhosAcessiveis': 'tem'},
        'status': 'publicada',
        'resumo': {'total': 2, 'somaNotas': 9},
        'atualizadoEm': Timestamp.fromDate(DateTime(2026, 9, 12)),
      });

      final copia = AreaVerde.fromMap(original.id, original.toFirestore());

      expect(copia.nome, original.nome);
      expect(copia.atividades, original.atividades);
      expect(copia.acessibilidade, original.acessibilidade);
      expect(copia.horario.abreEm, 360);
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

    test('busca ignora maiúscula e acento (RF13)', () {
      final area = AreaVerde.fromMap('x', {
        'nome': 'Praça do Ipê Amarelo',
        'bairro': 'Jardim Primavera',
        'cidade': 'São Paulo',
      });

      expect(area.correspondeBusca('praca do ipe'), isTrue);
      expect(area.correspondeBusca('PRIMAVERA'), isTrue);
      expect(area.correspondeBusca('sao paulo'), isTrue);
      expect(area.correspondeBusca('Aracaju'), isFalse);
      expect(area.correspondeBusca('  '), isTrue);
    });
  });

  group('Horario (minutos desde a meia-noite)', () {
    const horario = Horario(abreEm: 360, fechaEm: 1200); // 06:00 às 20:00

    test('aberto dentro do intervalo, fechado fora', () {
      // 01/01/2026 é quinta-feira
      expect(horario.estaAberto(DateTime(2026, 1, 1, 6, 0)), isTrue);
      expect(horario.estaAberto(DateTime(2026, 1, 1, 19, 59)), isTrue);
      expect(horario.estaAberto(DateTime(2026, 1, 1, 20, 0)), isFalse);
      expect(horario.estaAberto(DateTime(2026, 1, 1, 5, 59)), isFalse);
    });

    test('fechado no dia em que não abre', () {
      const semSegunda = Horario(
          abreEm: 360, fechaEm: 1200, diasAbertos: [2, 3, 4, 5, 6, 7]);
      // 05/01/2026 é segunda-feira
      expect(semSegunda.estaAberto(DateTime(2026, 1, 5, 10, 0)), isFalse);
      expect(semSegunda.estaAberto(DateTime(2026, 1, 6, 10, 0)), isTrue);
    });

    test('24h está sempre aberto', () {
      const h = Horario(abreEm: 0, fechaEm: 0, vinteQuatroHoras: true);
      expect(h.estaAberto(DateTime(2026, 1, 1, 3, 0)), isTrue);
    });

    test('horário inválido (fecha antes de abrir) nunca aparece aberto', () {
      const h = Horario(abreEm: 1200, fechaEm: 360);
      expect(h.valido, isFalse);
      expect(h.estaAberto(DateTime(2026, 1, 1, 21, 0)), isFalse);
    });

    test('formata para exibir na tela', () {
      expect(Horario.formatar(360), '06:00');
      expect(Horario.formatar(1230), '20:30');
    });
  });

  group('ResumoAvaliacoes (somas inteiras)', () {
    test('sem avaliações tem média 0, sem divisão por zero', () {
      expect(const ResumoAvaliacoes().media, 0);
    });

    test('adicionar, substituir e remover mantêm a conta exata', () {
      var r = const ResumoAvaliacoes();
      r = r.adicionar(_avaliacao(5)).adicionar(_avaliacao(4));
      expect(r.total, 2);
      expect(r.somaNotas, 9);
      expect(r.media, 4.5);

      r = r.substituir(_avaliacao(5), _avaliacao(3));
      expect(r.total, 2);
      expect(r.somaNotas, 7);

      r = r.remover(_avaliacao(3)).remover(_avaliacao(4));
      expect(r.total, 0);
      expect(r.somaNotas, 0);
      expect(r.somaLimpeza, 0);
    });
  });

  test('Evento: período inválido é detectado', () {
    final e = Evento(
      id: 'e',
      areaId: 'a',
      titulo: 'Ioga',
      tipo: TipoEvento.ioga,
      inicio: DateTime(2026, 12, 1, 10),
      fim: DateTime(2026, 12, 1, 9),
      organizadorId: 'u',
      organizadorNome: 'Marina',
    );
    expect(e.periodoValido, isFalse);
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
