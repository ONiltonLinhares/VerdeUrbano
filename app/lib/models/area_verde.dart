import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'enums.dart';

/// Coleção `areas_verdes/{id}`. Ver docs/modelagem-dados.md, seção 3.
class AreaVerde {
  AreaVerde({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.localizacao,
    required this.fotos,
    required this.horario,
    required this.atividades,
    required this.estrutura,
    required this.acessibilidade,
    required this.fonte,
    required this.atualizadoEm,
    required this.status,
    required this.resumo,
  });

  final String id;
  final String nome;
  final TipoArea tipo;
  final String endereco;
  final String bairro;
  final String cidade;
  final GeoPoint localizacao;
  final List<String> fotos;
  final Horario horario;
  final List<Atividade> atividades;
  final Map<Recurso, Disponibilidade> estrutura;
  final Map<RecursoAcessibilidade, Disponibilidade> acessibilidade;
  final String fonte; // RF08
  final DateTime atualizadoEm; // RF08
  final StatusArea status;
  final ResumoAvaliacoes resumo;

  /// Selo "Acessível" do card: rampa e caminho acessível confirmados.
  bool get isAcessivel =>
      acessibilidade[RecursoAcessibilidade.rampas] == Disponibilidade.tem &&
      acessibilidade[RecursoAcessibilidade.caminhosAcessiveis] ==
          Disponibilidade.tem;

  /// Distância em metros (RF02).
  double distanciaAte(double latitude, double longitude) =>
      Geolocator.distanceBetween(
        latitude,
        longitude,
        localizacao.latitude,
        localizacao.longitude,
      );

  bool estaAberta(DateTime agora) => horario.estaAberto(agora);

  factory AreaVerde.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AreaVerde.fromMap(doc.id, doc.data() ?? const {});
  }

  /// Usado tanto pelo Firestore quanto pela cópia offline (tabela local).
  factory AreaVerde.fromMap(String id, Map<String, dynamic> d) {
    final estruturaRaw = (d['estrutura'] as Map?) ?? const {};
    final acessRaw = (d['acessibilidade'] as Map?) ?? const {};

    return AreaVerde(
      id: id,
      nome: d['nome'] as String? ?? '',
      tipo: enumPorNome(TipoArea.values, d['tipo'], TipoArea.parque),
      endereco: d['endereco'] as String? ?? '',
      bairro: d['bairro'] as String? ?? '',
      cidade: d['cidade'] as String? ?? '',
      localizacao: _lerGeoPoint(d['localizacao']),
      fotos: List<String>.from(d['fotos'] as List? ?? const []),
      horario: Horario.fromMap((d['horario'] as Map?)?.cast<String, dynamic>()),
      atividades: [
        for (final a in (d['atividades'] as List? ?? const []))
          if (Atividade.values.any((e) => e.name == a))
            Atividade.values.byName(a as String),
      ],
      // Recurso ausente no documento = "não informado" (RF07).
      estrutura: {
        for (final r in Recurso.values)
          r: enumPorNome(Disponibilidade.values, estruturaRaw[r.name],
              Disponibilidade.naoInformado),
      },
      acessibilidade: {
        for (final r in RecursoAcessibilidade.values)
          r: enumPorNome(Disponibilidade.values, acessRaw[r.name],
              Disponibilidade.naoInformado),
      },
      fonte: d['fonte'] as String? ?? 'Não informada',
      atualizadoEm: _lerData(d['atualizadoEm']),
      status: enumPorNome(StatusArea.values, d['status'], StatusArea.pendente),
      resumo: ResumoAvaliacoes.fromMap(
          (d['resumo'] as Map?)?.cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'tipo': tipo.name,
        'endereco': endereco,
        'bairro': bairro,
        'cidade': cidade,
        'localizacao': localizacao,
        'fotos': fotos,
        'horario': horario.toMap(),
        'atividades': atividades.map((a) => a.name).toList(),
        'estrutura': {for (final e in estrutura.entries) e.key.name: e.value.name},
        'acessibilidade': {
          for (final e in acessibilidade.entries) e.key.name: e.value.name
        },
        'fonte': fonte,
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
        'status': status.name,
        'resumo': resumo.toMap(),
      };

  /// Versão serializável em JSON para a tabela `locais_offline`
  /// (Timestamp e GeoPoint não são JSON).
  Map<String, dynamic> toJsonOffline() => {
        ...toFirestore(),
        'localizacao': {
          'lat': localizacao.latitude,
          'lng': localizacao.longitude,
        },
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  static GeoPoint _lerGeoPoint(Object? v) {
    if (v is GeoPoint) return v;
    if (v is Map) {
      return GeoPoint(
        (v['lat'] as num?)?.toDouble() ?? 0,
        (v['lng'] as num?)?.toDouble() ?? 0,
      );
    }
    return const GeoPoint(0, 0);
  }

  static DateTime _lerData(Object? v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime(1970);
    return DateTime(1970);
  }
}

/// Embutido em `areas_verdes/{id}.horario`.
class Horario {
  const Horario({
    required this.abre,
    required this.fecha,
    required this.vinteQuatroHoras,
  });

  final String abre; // "06:00"
  final String fecha; // "20:00"
  final bool vinteQuatroHoras;

  bool estaAberto(DateTime agora) {
    if (vinteQuatroHoras) return true;
    final atual = agora.hour * 60 + agora.minute;
    final inicio = _minutos(abre);
    final fim = _minutos(fecha);
    if (inicio == null || fim == null) return false;
    return atual >= inicio && atual < fim;
  }

  static int? _minutos(String hhmm) {
    final partes = hhmm.split(':');
    if (partes.length != 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  factory Horario.fromMap(Map<String, dynamic>? d) => Horario(
        abre: d?['abre'] as String? ?? '',
        fecha: d?['fecha'] as String? ?? '',
        vinteQuatroHoras: d?['vinteQuatroHoras'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'abre': abre,
        'fecha': fecha,
        'vinteQuatroHoras': vinteQuatroHoras,
      };
}

/// Embutido em `areas_verdes/{id}.resumo`. Guarda somas, não médias:
/// uma avaliação nova só soma o valor dela (ver modelagem, seção 3.1).
class ResumoAvaliacoes {
  const ResumoAvaliacoes({
    this.total = 0,
    this.somaNotas = 0,
    this.somaLimpeza = 0,
    this.somaConservacao = 0,
    this.somaAcessibilidade = 0,
  });

  final int total;
  final double somaNotas;
  final double somaLimpeza;
  final double somaConservacao;
  final double somaAcessibilidade;

  double get media => total == 0 ? 0 : somaNotas / total;
  double get mediaLimpeza => total == 0 ? 0 : somaLimpeza / total;
  double get mediaConservacao => total == 0 ? 0 : somaConservacao / total;
  double get mediaAcessibilidade => total == 0 ? 0 : somaAcessibilidade / total;

  factory ResumoAvaliacoes.fromMap(Map<String, dynamic>? d) => ResumoAvaliacoes(
        total: (d?['total'] as num?)?.toInt() ?? 0,
        somaNotas: (d?['somaNotas'] as num?)?.toDouble() ?? 0,
        somaLimpeza: (d?['somaLimpeza'] as num?)?.toDouble() ?? 0,
        somaConservacao: (d?['somaConservacao'] as num?)?.toDouble() ?? 0,
        somaAcessibilidade: (d?['somaAcessibilidade'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'somaNotas': somaNotas,
        'somaLimpeza': somaLimpeza,
        'somaConservacao': somaConservacao,
        'somaAcessibilidade': somaAcessibilidade,
      };
}
