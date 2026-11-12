import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Banco SQLite no aparelho. Guarda o que NÃO pode ou não precisa ir para a
/// nuvem: o diário de bem-estar (RNF04) e as cópias offline (RF11/RF12).
/// Esquema documentado em docs/modelagem-dados.md, seção 5.
class BancoLocal {
  BancoLocal._();
  static final instancia = BancoLocal._();

  static const _nomeArquivo = 'verde_urbano.db';
  static const _versao = 1;

  Database? _db;

  Future<Database> get db async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final caminho = join(await getDatabasesPath(), _nomeArquivo);
    return openDatabase(caminho, version: _versao, onCreate: _criar);
  }

  Future<void> _criar(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE registros_diario (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        area_id     TEXT,
        area_nome   TEXT NOT NULL,
        humor       TEXT NOT NULL,
        atividades  TEXT NOT NULL,
        anotacao    TEXT,
        data_hora   TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE locais_offline (
        area_id     TEXT PRIMARY KEY,
        dados_json  TEXT NOT NULL,
        baixado_em  TEXT NOT NULL
      )
    ''');
  }
}
