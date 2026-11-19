/// Validações dos formulários. Os mesmos limites estão no firestore.rules:
/// a tela avisa antes, o banco garante.
abstract final class Validadores {
  static final _email = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.\-]+$');

  static String? obrigatorio(String? v, {String campo = 'Campo'}) =>
      (v == null || v.trim().isEmpty) ? '$campo é obrigatório.' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail.';
    if (!_email.hasMatch(v.trim())) return 'E-mail inválido.';
    return null;
  }

  static String? senha(String? v) {
    if (v == null || v.isEmpty) return 'Informe sua senha.';
    if (v.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
    return null;
  }

  /// Regra: nome de 1 a 60 caracteres (usuarios e autorNome).
  static String? nome(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe seu nome.';
    if (t.length > 60) return 'Nome muito longo (máx. 60).';
    return null;
  }

  static String? texto(String? v, {int min = 0, required int max, String? campo}) {
    final t = v?.trim() ?? '';
    if (t.length < min) {
      return min == 1 ? '${campo ?? 'Campo'} é obrigatório.' : 'Escreva pelo menos $min caracteres.';
    }
    if (t.length > max) return 'Máximo de $max caracteres.';
    return null;
  }

  static String? numero(String? v, {required double min, required double max, String campo = 'Valor'}) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (n == null || n < min || n > max) return '$campo inválido.';
    return null;
  }

  static final _hora = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');

  static String? hora(String? v) =>
      (v == null || !_hora.hasMatch(v.trim())) ? 'Use o formato HH:MM.' : null;

  /// "06:30" → 390
  static int minutosDe(String hhmm) {
    final p = hhmm.trim().split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }
}
