import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'avaliacao.dart';
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
    this.criadoPor,
  });

  final String id;
  final String nome;
  final TipoArea tipo;
  final String endereco;
  final String bairro;
  final String cidade;
  final GeoPoint localizacao;

  /// Fotos oficiais (URLs públicas, cadastradas pelo admin).
  /// Fotos enviadas pela comunidade ficam na subcoleção `fotos`.
  final List<String> fotos;
  final Horario horario;
  final List<Atividade> atividades;
  final Map<Recurso, Disponibilidade> estrutura;
  final Map<RecursoAcessibilidade, Disponibilidade> acessibilidade;
  final String fonte; // RF08
  final DateTime atualizadoEm; // RF08
  final StatusArea status;
  final ResumoAvaliacoes resumo;

  /// uid de quem sugeriu o local (null quando cadastrado pelo admin).
  /// Permite ao morador acompanhar a própria sugestão enquanto está pendente.
  final String? criadoPor;

  /// Selo "Acessível" do card: rampa e caminho acessível confirmados.
  bool get isAcessivel =>
      acessibilidade[RecursoAcessibilidade.rampas] == Disponibilidade.tem &&
      acessibilidade[RecursoAcessibilidade.caminhosAcessiveis] ==
          Disponibilidade.tem;

  /// Distância em metros (RF02). É `double` porque o GPS devolve valor
  /// quebrado (ex.: 652,38 m).
  double distanciaAte(double latitude, double longitude) =>
      Geolocator.distanceBetween(
        latitude,
        longitude,
        localizacao.latitude,
        localizacao.longitude,
      );

  bool estaAberta(DateTime agora) => horario.estaAberto(agora);

  /// RF13: busca por nome, bairro ou cidade, sem diferenciar maiúscula/acento.
  /// Feita no aparelho: o Firestore não tem busca por "contém" (ver seção 8
  /// da modelagem).
  bool correspondeBusca(String termo) {
    final t = normalizarTexto(termo);
    if (t.isEmpty) return true;
    return normalizarTexto('$nome $bairro $cidade').contains(t);
  }

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
      criadoPor: d['criadoPor'] as String?,
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
        'criadoPor': criadoPor,
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

/// Minúsculas e sem acento: "Praça" e "praca" passam a ser iguais na busca.
String normalizarTexto(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final buffer = StringBuffer();
  for (final c in s.toLowerCase().trim().split('')) {
    final i = de.indexOf(c);
    buffer.write(i >= 0 ? para[i] : c);
  }
  return buffer.toString();
}

/// Embutido em `areas_verdes/{id}.horario`.
///
/// Horário em **minutos desde a meia-noite** (`int`), não em texto "06:00":
/// comparar fica direto (`agora >= abreEm`) e não há texto para quebrar.
/// 06:00 = 360 · 20:00 = 1200.
class Horario {
  const Horario({
    required this.abreEm,
    required this.fechaEm,
    this.vinteQuatroHoras = false,
    this.diasAbertos = todosOsDias,
  });

  /// `DateTime.monday` (1) … `DateTime.sunday` (7).
  static const todosOsDias = [1, 2, 3, 4, 5, 6, 7];

  final int abreEm;
  final int fechaEm;
  final bool vinteQuatroHoras;
  final List<int> diasAbertos;

  bool get valido =>
      vinteQuatroHoras ||
      (abreEm >= 0 && fechaEm <= 24 * 60 && abreEm < fechaEm);

  bool estaAberto(DateTime agora) {
    if (!diasAbertos.contains(agora.weekday)) return false;
    if (vinteQuatroHoras) return true;
    if (!valido) return false;
    final minuto = agora.hour * 60 + agora.minute;
    return minuto >= abreEm && minuto < fechaEm;
  }

  /// 1200 → "20:00". Usado na tela ("Aberto até 20h").
  static String formatar(int minutos) {
    final h = (minutos ~/ 60).toString().padLeft(2, '0');
    final m = (minutos % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory Horario.fromMap(Map<String, dynamic>? d) => Horario(
        abreEm: (d?['abreEm'] as num?)?.toInt() ?? 0,
        fechaEm: (d?['fechaEm'] as num?)?.toInt() ?? 0,
        vinteQuatroHoras: d?['vinteQuatroHoras'] as bool? ?? false,
        diasAbertos: d?['diasAbertos'] is List
            ? List<int>.from(d!['diasAbertos'] as List)
            : todosOsDias,
      );

  Map<String, dynamic> toMap() => {
        'abreEm': abreEm,
        'fechaEm': fechaEm,
        'vinteQuatroHoras': vinteQuatroHoras,
        'diasAbertos': diasAbertos,
      };
}

/// Embutido em `areas_verdes/{id}.resumo`.
///
/// Guarda **somas inteiras**, não médias: notas são `int` de 1 a 5, e soma de
/// inteiros é inteiro — a conta fica exata, sem erro de arredondamento.
/// A média (`double`) é calculada só na hora de mostrar.
class ResumoAvaliacoes {
  const ResumoAvaliacoes({
    this.total = 0,
    this.somaNotas = 0,
    this.somaLimpeza = 0,
    this.somaConservacao = 0,
    this.somaAcessibilidade = 0,
  });

  final int total;
  final int somaNotas;
  final int somaLimpeza;
  final int somaConservacao;
  final int somaAcessibilidade;

  double get media => total == 0 ? 0 : somaNotas / total;
  double get mediaLimpeza => total == 0 ? 0 : somaLimpeza / total;
  double get mediaConservacao => total == 0 ? 0 : somaConservacao / total;
  double get mediaAcessibilidade => total == 0 ? 0 : somaAcessibilidade / total;

  /// Avaliação nova: soma as notas dela e conta +1.
  ResumoAvaliacoes adicionar(Avaliacao a) => ResumoAvaliacoes(
        total: total + 1,
        somaNotas: somaNotas + a.nota,
        somaLimpeza: somaLimpeza + a.notaLimpeza,
        somaConservacao: somaConservacao + a.notaConservacao,
        somaAcessibilidade: somaAcessibilidade + a.notaAcessibilidade,
      );

  /// Avaliação excluída: tira as notas dela e conta −1.
  ResumoAvaliacoes remover(Avaliacao a) => ResumoAvaliacoes(
        total: total - 1,
        somaNotas: somaNotas - a.nota,
        somaLimpeza: somaLimpeza - a.notaLimpeza,
        somaConservacao: somaConservacao - a.notaConservacao,
        somaAcessibilidade: somaAcessibilidade - a.notaAcessibilidade,
      );

  /// Avaliação editada: troca as notas antigas pelas novas, total igual.
  ResumoAvaliacoes substituir(Avaliacao antiga, Avaliacao nova) =>
      remover(antiga).adicionar(nova);

  factory ResumoAvaliacoes.fromMap(Map<String, dynamic>? d) => ResumoAvaliacoes(
        total: (d?['total'] as num?)?.toInt() ?? 0,
        somaNotas: (d?['somaNotas'] as num?)?.toInt() ?? 0,
        somaLimpeza: (d?['somaLimpeza'] as num?)?.toInt() ?? 0,
        somaConservacao: (d?['somaConservacao'] as num?)?.toInt() ?? 0,
        somaAcessibilidade: (d?['somaAcessibilidade'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'somaNotas': somaNotas,
        'somaLimpeza': somaLimpeza,
        'somaConservacao': somaConservacao,
        'somaAcessibilidade': somaAcessibilidade,
      };
}
