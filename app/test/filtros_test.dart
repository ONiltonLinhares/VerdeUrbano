import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verde_urbano/estado/areas_estado.dart';
import 'package:verde_urbano/models/area_verde.dart';
import 'package:verde_urbano/models/enums.dart';

AreaVerde _area(
  String id,
  String nome, {
  required String bairro,
  List<Atividade> atividades = const [],
  Map<Recurso, Disponibilidade> estrutura = const {},
  Map<RecursoAcessibilidade, Disponibilidade> acessibilidade = const {},
}) =>
    AreaVerde(
      id: id,
      nome: nome,
      tipo: TipoArea.parque,
      endereco: 'Rua A, 1',
      bairro: bairro,
      cidade: 'São Paulo',
      localizacao: const GeoPoint(-23.58, -46.65),
      fotos: const [],
      horario: const Horario(abreEm: 360, fechaEm: 1200),
      atividades: atividades,
      estrutura: estrutura,
      acessibilidade: acessibilidade,
      fonte: 'teste',
      atualizadoEm: DateTime(2026, 11, 1),
      status: StatusArea.publicada,
      resumo: const ResumoAvaliacoes(),
    );

void main() {
  final estado = AreasEstado.instancia;

  setUp(() {
    estado.limparFiltros();
    estado.definirBusca('');
    estado.definirAreasParaTeste([
      _area('1', 'Parque das Águas Claras',
          bairro: 'Jardim Primavera',
          atividades: [Atividade.caminhada, Atividade.corrida],
          estrutura: {Recurso.banheiros: Disponibilidade.tem},
          acessibilidade: {RecursoAcessibilidade.rampas: Disponibilidade.tem}),
      _area('2', 'Praça do Ipê Amarelo',
          bairro: 'Vila Mariana',
          atividades: [Atividade.descanso],
          estrutura: {Recurso.banheiros: Disponibilidade.naoTem}),
      _area('3', 'Bosque do Jequitibá',
          bairro: 'Butantã',
          atividades: [Atividade.trilhas, Atividade.caminhada],
          estrutura: {Recurso.banheiros: Disponibilidade.naoInformado}),
    ]);
  });

  test('sem filtros mostra todos', () {
    expect(estado.filtradas().length, 3);
    expect(estado.quantidadeFiltros, 0);
  });

  test('RF13: busca por nome ou bairro ignora acentos', () {
    estado.definirBusca('praca');
    expect(estado.filtradas().map((a) => a.id), ['2']);
    estado.definirBusca('butanta');
    expect(estado.filtradas().map((a) => a.id), ['3']);
  });

  test('RF04: filtro por atividade exige todas as selecionadas', () {
    estado.alternar(estado.atividades, Atividade.caminhada);
    expect(estado.filtradas().map((a) => a.id).toSet(), {'1', '3'});
    estado.alternar(estado.atividades, Atividade.corrida);
    expect(estado.filtradas().map((a) => a.id), ['1']);
  });

  test('RF05/RF07: "não informado" não passa no filtro de estrutura', () {
    estado.alternar(estado.estrutura, Recurso.banheiros);
    expect(estado.filtradas().map((a) => a.id), ['1']);
  });

  test('filtro de acessibilidade e contador de filtros', () {
    estado.alternar(estado.acessibilidade, RecursoAcessibilidade.rampas);
    expect(estado.filtradas().map((a) => a.id), ['1']);
    expect(estado.quantidadeFiltros, 1);
    estado.limparFiltros();
    expect(estado.quantidadeFiltros, 0);
  });

  test('alternar duas vezes remove o filtro', () {
    estado.alternar(estado.atividades, Atividade.trilhas);
    estado.alternar(estado.atividades, Atividade.trilhas);
    expect(estado.atividades, isEmpty);
  });
}
