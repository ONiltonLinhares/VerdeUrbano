import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/area_verde.dart';
import '../models/enums.dart';

/// Locais fictícios do protótipo de alta fidelidade, para popular o Firestore
/// nos testes e na apresentação. Disponível só para admin (tela Admin).
abstract final class DadosExemplo {
  static const _t = Disponibilidade.tem;
  static const _n = Disponibilidade.naoTem;
  static const _i = Disponibilidade.naoInformado;

  static List<AreaVerde> areas() {
    final hoje = DateTime.now();
    AreaVerde area({
      required String id,
      required String nome,
      required TipoArea tipo,
      required String endereco,
      required String bairro,
      required double lat,
      required double lng,
      required Horario horario,
      required List<Atividade> atividades,
      required List<Disponibilidade> estrutura,
      required List<Disponibilidade> acess,
      required String fonte,
    }) =>
        AreaVerde(
          id: id,
          nome: nome,
          tipo: tipo,
          endereco: endereco,
          bairro: bairro,
          cidade: 'São Paulo',
          localizacao: GeoPoint(lat, lng),
          fotos: const [],
          horario: horario,
          atividades: atividades,
          estrutura: {
            for (var i = 0; i < Recurso.values.length; i++)
              Recurso.values[i]: estrutura[i],
          },
          acessibilidade: {
            for (var i = 0; i < RecursoAcessibilidade.values.length; i++)
              RecursoAcessibilidade.values[i]: acess[i],
          },
          fonte: fonte,
          atualizadoEm: hoje,
          status: StatusArea.publicada,
          resumo: const ResumoAvaliacoes(),
        );

    // Ordem da estrutura: bancos, banheiros, bebedouros, equip. esportivos, estacionamento.
    // Ordem da acessibilidade: rampas, caminhos acessíveis, banheiro adaptado, iluminação.
    return [
      area(
        id: 'parque-aguas-claras',
        nome: 'Parque das Águas Claras',
        tipo: TipoArea.parque,
        endereco: 'Rua das Palmeiras, 1200',
        bairro: 'Jardim Primavera',
        lat: -23.5870,
        lng: -46.6580,
        horario: const Horario(abreEm: 360, fechaEm: 1200),
        atividades: const [
          Atividade.caminhada,
          Atividade.corrida,
          Atividade.playground,
          Atividade.descanso,
        ],
        estrutura: const [_t, _t, _t, _n, _t],
        acess: const [_t, _t, _i, _t],
        fonte: 'Prefeitura + contribuições da comunidade (dados de exemplo)',
      ),
      area(
        id: 'praca-ipe-amarelo',
        nome: 'Praça do Ipê Amarelo',
        tipo: TipoArea.praca,
        endereco: 'Praça do Ipê, s/n',
        bairro: 'Vila Mariana',
        lat: -23.5890,
        lng: -46.6345,
        horario: const Horario(abreEm: 0, fechaEm: 1440, vinteQuatroHoras: true),
        atividades: const [Atividade.descanso, Atividade.caminhada],
        estrutura: const [_t, _n, _i, _n, _n],
        acess: const [_t, _i, _n, _i],
        fonte: 'Comunidade (dados de exemplo)',
      ),
      area(
        id: 'bosque-jequitiba',
        nome: 'Bosque do Jequitibá',
        tipo: TipoArea.bosque,
        endereco: 'Av. dos Jequitibás, 455',
        bairro: 'Butantã',
        lat: -23.5710,
        lng: -46.7080,
        horario: const Horario(abreEm: 420, fechaEm: 1080),
        atividades: const [Atividade.trilhas, Atividade.caminhada, Atividade.descanso],
        estrutura: const [_t, _t, _t, _n, _i],
        acess: const [_n, _n, _n, _n],
        fonte: 'Prefeitura (dados de exemplo)',
      ),
      area(
        id: 'horta-girassol',
        nome: 'Horta Comunitária Girassol',
        tipo: TipoArea.horta,
        endereco: 'Rua Girassol, 88',
        bairro: 'Pinheiros',
        lat: -23.5640,
        lng: -46.6900,
        horario: const Horario(
            abreEm: 480, fechaEm: 1020, diasAbertos: [2, 3, 4, 5, 6, 7]),
        atividades: const [Atividade.descanso],
        estrutura: const [_t, _i, _t, _n, _n],
        acess: const [_t, _t, _i, _i],
        fonte: 'Associação de moradores (dados de exemplo)',
      ),
      area(
        id: 'parque-linear-corrego-azul',
        nome: 'Parque Linear do Córrego Azul',
        tipo: TipoArea.parque,
        endereco: 'Av. Córrego Azul, 3000',
        bairro: 'Moema',
        lat: -23.6010,
        lng: -46.6650,
        horario: const Horario(abreEm: 300, fechaEm: 1320),
        atividades: const [
          Atividade.corrida,
          Atividade.caminhada,
          Atividade.quadras,
          Atividade.playground,
        ],
        estrutura: const [_t, _t, _t, _t, _t],
        acess: const [_t, _t, _t, _t],
        fonte: 'Prefeitura (dados de exemplo)',
      ),
    ];
  }

  /// Grava com ids fixos (pode rodar mais de uma vez). O `resumo` só é
  /// enviado se a área ainda não existe, para não zerar avaliações reais.
  static Future<void> popular() async {
    final db = FirebaseFirestore.instance;
    for (final a in areas()) {
      final ref = db.collection('areas_verdes').doc(a.id);
      final existe = (await ref.get()).exists;
      final dados = a.toFirestore();
      if (existe) dados.remove('resumo');
      await ref.set(dados, SetOptions(merge: true));
    }
  }
}
