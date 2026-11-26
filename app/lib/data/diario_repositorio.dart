import 'package:flutter/foundation.dart';

import '../core/erros.dart';
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

  /// Lê os registros, do mais recente para o mais antigo. Uma linha
  /// corrompida é ignorada; uma falha de leitura mantém a lista atual.
  Future<void> carregar() async {
    try {
      final db = await BancoLocal.instancia.db;
      final linhas =
          await db.query('registros_diario', orderBy: 'data_hora DESC');
      final lidos = <RegistroDiario>[];
      for (final l in linhas) {
        try {
          lidos.add(RegistroDiario.fromSqlite(l));
        } catch (_) {}
      }
      _registros = lidos;
      _carregado = true;
    } catch (e) {
      debugPrint('Diário: não foi possível ler os registros ($e)');
    }
    notifyListeners();
  }

  /// Cria (id nulo) ou atualiza (id preenchido).
  Future<void> salvar(RegistroDiario r) async {
    try {
      final db = await BancoLocal.instancia.db;
      if (r.id == null) {
        await db.insert('registros_diario', r.toSqlite());
      } else {
        await db.update('registros_diario', r.toSqlite(),
            where: 'id = ?', whereArgs: [r.id]);
      }
    } catch (_) {
      throw const ErroApp('Não foi possível salvar o registro no aparelho.');
    }
    await carregar();
  }

  Future<void> excluir(int id) async {
    try {
      final db = await BancoLocal.instancia.db;
      await db.delete('registros_diario', where: 'id = ?', whereArgs: [id]);
    } catch (_) {
      throw const ErroApp('Não foi possível excluir o registro.');
    }
    await carregar();
  }
}
