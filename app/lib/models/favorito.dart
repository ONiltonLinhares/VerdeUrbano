import 'package:cloud_firestore/cloud_firestore.dart';

/// Subcoleção `usuarios/{uid}/favoritos/{areaId}`.
///
/// O id do documento é o id da área: não existe favorito duplicado.
/// Guarda só a referência, sem copiar nome/foto/horário da área: a aba
/// "Salvos" cruza com as áreas já carregadas (que estão no cache). Assim,
/// se a área mudar de nome ou horário, o favorito nunca fica desatualizado.
class Favorito {
  Favorito({required this.areaId, required this.adicionadoEm});

  final String areaId;
  final DateTime adicionadoEm;

  factory Favorito.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Favorito(
      areaId: doc.id,
      adicionadoEm: (d['adicionadoEm'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'adicionadoEm': Timestamp.fromDate(adicionadoEm),
      };
}
