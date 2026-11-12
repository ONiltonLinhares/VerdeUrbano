import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Cores do guia visual do protótipo de alta fidelidade (Unidade I).
/// Contrastes medidos sobre branco; modo claro como padrão (RNF02).
abstract final class Cores {
  static const floresta = Color(0xFF1E5A43); // principal · 8,1:1
  static const folhaClara = Color(0xFFE2F0E6); // fundo de destaque
  static const terra = Color(0xFF9A4F26); // complemento · 6,0:1
  static const areia = Color(0xFFF3EDE2); // fundo de bloco
  static const fundo = Color(0xFFFBFAF7);
  static const texto = Color(0xFF1A2420); // 15,3:1
  static const texto2 = Color(0xFF4D5852); // 7,1:1
  static const estrela = Color(0xFFB8652F);
  static const naoInformado = Color(0xFF8A5A00); // 5,9:1
  static const voce = Color(0xFF2F6FB0); // posição do usuário no mapa
}

/// Fraunces nos títulos (acolhedor), Nunito Sans no corpo (leitura rápida).
/// Texto de corpo nunca abaixo de 15 px.
ThemeData criarTema() {
  final corpo = GoogleFonts.nunitoSansTextTheme();
  final titulo = GoogleFonts.fraunces(fontWeight: FontWeight.w600, color: Cores.texto);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Cores.fundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Cores.floresta,
      primary: Cores.floresta,
      secondary: Cores.terra,
      surface: Cores.fundo,
      onSurface: Cores.texto,
    ),
    textTheme: corpo.copyWith(
      displaySmall: titulo.copyWith(fontSize: 30),
      headlineSmall: titulo.copyWith(fontSize: 21),
      titleLarge: titulo.copyWith(fontSize: 20),
      bodyLarge: corpo.bodyLarge?.copyWith(fontSize: 16, color: Cores.texto),
      bodyMedium: corpo.bodyMedium?.copyWith(fontSize: 15, color: Cores.texto2),
    ),
    // Áreas de toque de no mínimo 44 × 44 px (justificativas, item 6).
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.floresta,
        minimumSize: const Size(44, 52),
        textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Cores.floresta,
        minimumSize: const Size(44, 52),
        side: const BorderSide(color: Cores.floresta),
        textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Cores.folhaClara,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
  );
}
