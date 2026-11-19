import '../models/area_verde.dart';

/// Formatação de textos exibidos na tela (sem depender do pacote intl).

String doisDigitos(int n) => n.toString().padLeft(2, '0');

/// 12/09/2026
String formatarData(DateTime d) =>
    '${doisDigitos(d.day)}/${doisDigitos(d.month)}/${d.year}';

/// 12/09/2026 às 17h40
String formatarDataHora(DateTime d) =>
    '${formatarData(d)} às ${doisDigitos(d.hour)}h${doisDigitos(d.minute)}';

/// "Hoje, 17h40", "Ontem, 09h05" ou "12/09, 17h40".
String formatarDiaHora(DateTime d, {DateTime? agora}) {
  final hoje = agora ?? DateTime.now();
  final dia = DateTime(d.year, d.month, d.day);
  final diaHoje = DateTime(hoje.year, hoje.month, hoje.day);
  final diff = diaHoje.difference(dia).inDays;
  final hora = '${doisDigitos(d.hour)}h${doisDigitos(d.minute)}';
  if (diff == 0) return 'Hoje, $hora';
  if (diff == 1) return 'Ontem, $hora';
  return '${doisDigitos(d.day)}/${doisDigitos(d.month)}, $hora';
}

/// "há 3 dias", "há 1 semana" — usado nas avaliações do protótipo.
String tempoRelativo(DateTime d, {DateTime? agora}) {
  final diff = (agora ?? DateTime.now()).difference(d);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'há ${diff.inHours} h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7) return 'há ${diff.inDays} dias';
  final semanas = diff.inDays ~/ 7;
  if (diff.inDays < 30) return semanas == 1 ? 'há 1 semana' : 'há $semanas semanas';
  final meses = diff.inDays ~/ 30;
  if (diff.inDays < 365) return meses == 1 ? 'há 1 mês' : 'há $meses meses';
  return formatarData(d);
}

/// 650 m · 2,4 km
String formatarDistancia(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  return '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// 4,7
String formatarNota(double nota) => nota.toStringAsFixed(1).replaceAll('.', ',');

/// 360 → "6h" · 1230 → "20h30"
String horaCurta(int minutos) {
  final h = minutos ~/ 60;
  final m = minutos % 60;
  return m == 0 ? '${h}h' : '${h}h${doisDigitos(m)}';
}

/// "Aberto até 20h", "Aberto 24h" ou "Fechado agora" (card do protótipo).
String situacaoHorario(Horario h, DateTime agora) {
  if (!h.estaAberto(agora)) return 'Fechado agora';
  if (h.vinteQuatroHoras) return 'Aberto 24h';
  return 'Aberto até ${horaCurta(h.fechaEm)}';
}

/// "todos os dias, 6h às 20h" (página do local).
String descricaoHorario(Horario h) {
  const nomes = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  final dias = h.diasAbertos.length == 7
      ? 'todos os dias'
      : (List<int>.from(h.diasAbertos)..sort()).map((d) => nomes[d - 1]).join(', ');
  if (h.vinteQuatroHoras) return '$dias, 24 horas';
  return '$dias, ${horaCurta(h.abreEm)} às ${horaCurta(h.fechaEm)}';
}

/// Tempo estimado por modo de deslocamento (tela Rota do protótipo).
/// Velocidades médias urbanas: a pé 4,8 km/h, bicicleta 15 km/h,
/// ônibus 18 km/h + 5 min de espera. É uma estimativa: o trajeto exato
/// é calculado pelo app de mapas ao iniciar a navegação.
int minutosEstimados(double metros, String modo) {
  switch (modo) {
    case 'bicicleta':
      return (metros / 250).ceil().clamp(1, 999);
    case 'onibus':
      return ((metros / 300).ceil() + 5).clamp(1, 999);
    default:
      return (metros / 80).ceil().clamp(1, 999);
  }
}
