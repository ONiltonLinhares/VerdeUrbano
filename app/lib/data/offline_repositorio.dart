import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../core/erros.dart';
import '../models/area_verde.dart';
import 'banco_local.dart';

/// Local salvo para consulta sem internet (RF11, RF12).
class LocalOffline {
  const LocalOffline(this.area, this.baixadoEm);
  final AreaVerde area;
  final DateTime baixadoEm;
}

/// Cópias offline na tabela `locais_offline`.
/// RNF06: no máximo [maxLocais]; passando disso, o mais antigo sai sozinho.
class OfflineRepositorio extends ChangeNotifier {
  OfflineRepositorio._();
  static final instancia = OfflineRepositorio._();

  static const maxLocais = 20;

  final Map<String, LocalOffline> _locais = {};

  /// Mais recentes primeiro.
  List<LocalOffline> get locais => _locais.values.toList()
    ..sort((a, b) => b.baixadoEm.compareTo(a.baixadoEm));

  bool contem(String areaId) => _locais.containsKey(areaId);
  LocalOffline? obter(String areaId) => _locais[areaId];

  /// Espaço aproximado ocupado (mostrado na aba Salvos).
  int get bytesUsados => _locais.values
      .map((l) => utf8.encode(jsonEncode(l.area.toJsonOffline())).length)
      .fold(0, (a, b) => a + b);

  /// Lê a tabela. Falha de leitura não derruba o app: mantém o que já estava
  /// na memória e registra o motivo.
  Future<void> carregar() async {
    try {
      final db = await BancoLocal.instancia.db;
      final linhas = await db.query('locais_offline');
      _locais.clear();
      for (final l in linhas) {
        try {
          final id = l['area_id'] as String;
          final dados =
              jsonDecode(l['dados_json'] as String) as Map<String, dynamic>;
          _locais[id] = LocalOffline(
            AreaVerde.fromMap(id, dados),
            DateTime.parse(l['baixado_em'] as String),
          );
        } catch (_) {
          // linha corrompida: ignora em vez de derrubar o app
        }
      }
    } catch (e) {
      debugPrint('Offline: não foi possível ler os locais salvos ($e)');
    }
    notifyListeners();
  }

  /// Grava a cópia e, na mesma transação, descarta as que passam de
  /// [maxLocais] (as mais antigas saem primeiro).
  Future<void> salvar(AreaVerde area) async {
    try {
      final db = await BancoLocal.instancia.db;
      await db.transaction((txn) async {
        await txn.insert(
          'locais_offline',
          {
            'area_id': area.id,
            'dados_json': jsonEncode(area.toJsonOffline()),
            'baixado_em': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.delete(
          'locais_offline',
          where: 'area_id NOT IN (SELECT area_id FROM locais_offline '
              'ORDER BY baixado_em DESC LIMIT ?)',
          whereArgs: [maxLocais],
        );
      });
    } catch (_) {
      throw const ErroApp(
          'Não foi possível salvar no aparelho. Verifique o espaço de armazenamento.');
    }
    await carregar();
  }

  Future<void> remover(String areaId, {bool recarregar = true}) async {
    try {
      final db = await BancoLocal.instancia.db;
      await db.delete('locais_offline',
          where: 'area_id = ?', whereArgs: [areaId]);
    } catch (_) {
      throw const ErroApp('Não foi possível remover do aparelho.');
    }
    if (recarregar) await carregar();
  }
}
