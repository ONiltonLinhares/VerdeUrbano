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
        id: 'parque-sementeira',
        nome: 'Parque Augusto Franco (Sementeira)',
        tipo: TipoArea.parque,
        endereco: 'Avenida Jornalista Santos Santana',
        bairro: 'Jardins',
        lat: -10.944326855507292,
        lng: -37.05336036064472,
        horario: const Horario(abreEm: 300, fechaEm: 1320),
        atividades: const [
          Atividade.caminhada,
          Atividade.corrida,
          Atividade.playground,
          Atividade.quadras,
          Atividade.descanso,
        ],
        estrutura: const [_t, _t, _t, _t, _t],
        acess: const [_t, _t, _i, _t],
        fonte: 'Prefeitura de Aracaju + comunidade (dados de exemplo)',
      ),
      area(
        id: 'parque-cajueiros',
        nome: 'Parque dos Cajueiros',
        tipo: TipoArea.parque,
        endereco: 'Avenida Paulo Barreto de Menezes',
        bairro: 'Farolândia',
        lat: -10.961237621593355,
        lng: -37.05443123180779,
        horario: const Horario(abreEm: 300, fechaEm: 1320),
        atividades: const [
          Atividade.caminhada,
          Atividade.quadras,
          Atividade.descanso,
        ],
        estrutura: const [_t, _t, _i, _t, _i],
        acess: const [_t, _i, _i, _t],
        fonte: 'Prefeitura de Aracaju (dados de exemplo)',
      ),
      area(
        id: 'parque-da-cidade',
        nome: 'Parque da Cidade',
        tipo: TipoArea.bosque,
        endereco: 'Rua Fortaleza, s/n',
        bairro: 'Porto D\'antas',
        lat: -10.890142295532993,
        lng: -37.053927058212764,
        horario: const Horario(
            abreEm: 480, fechaEm: 1020, diasAbertos: [1, 2, 3, 4, 5, 6, 7]),
        atividades: const [
          Atividade.trilhas,
          Atividade.caminhada,
          Atividade.descanso,
        ],
        estrutura: const [_t, _t, _t, _n, _i],
        acess: const [_i, _n, _i, _i],
        fonte: 'Prefeitura de Aracaju (dados de exemplo)',
      ),
      area(
        id: 'parque-poxim',
        nome: 'Parque Ecológico Poxim',
        tipo: TipoArea.bosque,
        endereco: 'Avenida Tancredo Neves',
        bairro: 'Inácio Barbosa',
        lat: -10.953166672278314,
        lng: -37.05662309679133,
        horario: const Horario(abreEm: 420, fechaEm: 1080),
        atividades: const [Atividade.caminhada, Atividade.descanso],
        estrutura: const [_i, _n, _n, _n, _n],
        acess: const [_n, _n, _n, _n],
        fonte: 'Comunidade (dados de exemplo)',
      ),
      area(
        id: 'praca-fausto-cardoso',
        nome: 'Praça Fausto Cardoso',
        tipo: TipoArea.praca,
        endereco: 'Avenida Ivo do Prado',
        bairro: 'Centro',
        lat: -10.913201675997682,
        lng: -37.04868577413556,
        horario: const Horario(abreEm: 0, fechaEm: 1440, vinteQuatroHoras: true),
        atividades: const [Atividade.descanso, Atividade.caminhada],
        estrutura: const [_t, _n, _i, _n, _n],
        acess: const [_t, _t, _i, _t],
        fonte: 'Comunidade (dados de exemplo)',
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
