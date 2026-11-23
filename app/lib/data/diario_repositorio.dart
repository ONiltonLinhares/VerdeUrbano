import 'package:flutter/foundation.dart';

import '../models/registro_diario.dart';
import 'banco_local.dart';

/// Diário de bem-estar — CRUD 100% local na tabela `registros_diario`
/// (RNF04). Nada aqui usa Firebase: os dados ficam só no aparelho.
class DiarioRepositorio extends ChangeNotifier {
  DiarioRepositorio._();
  static final instancia = DiarioRepositorio._();

  List<RegistroDiario> _registros = [];
  bool _carregado = false;

  List<RegistroDiario> get registros => List.unmodifiable(_registros);
  bool get carregado => _carregado;

  Future<void> carregar() async {
    final db = await BancoLocal.instancia.db;
    final linhas = await db.query('registros_diario', orderBy: 'data_hora DESC');
    _registros = linhas.map(RegistroDiario.fromSqlite).toList();
    _carregado = true;
    notifyListeners();
  }

  /// Cria (id nulo) ou atualiza (id preenchido).
  Future<void> salvar(RegistroDiario r) async {
    final db = await BancoLocal.instancia.db;
    if (r.id == null) {
      await db.insert('registros_diario', r.toSqlite());
    } else {
      await db.update('registros_diario', r.toSqlite(),
          where: 'id = ?', whereArgs: [r.id]);
    }
    await carregar();
  }

  Future<void> excluir(int id) async {
    final db = await BancoLocal.instancia.db;
    await db.delete('registros_diario', where: 'id = ?', whereArgs: [id]);
    await carregar();
  }
}
