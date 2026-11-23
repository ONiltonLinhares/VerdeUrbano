import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/tema.dart';
import '../estado/conectividade_estado.dart';
import '../models/area_verde.dart';
import '../models/enums.dart';
import '../models/foto.dart';

/// Ícones do guia visual (traço, sempre acompanhados de texto).
IconData iconeTipo(TipoArea t) => switch (t) {
      TipoArea.parque => Icons.park_outlined,
      TipoArea.praca => Icons.deck_outlined,
      TipoArea.horta => Icons.grass_outlined,
      TipoArea.bosque => Icons.forest_outlined,
    };

IconData iconeAtividade(Atividade a) => switch (a) {
      Atividade.caminhada => Icons.directions_walk,
      Atividade.corrida => Icons.directions_run,
      Atividade.trilhas => Icons.hiking,
      Atividade.playground => Icons.child_care,
      Atividade.quadras => Icons.sports_basketball_outlined,
      Atividade.descanso => Icons.weekend_outlined,
    };

IconData iconeRecurso(Recurso r) => switch (r) {
      Recurso.bancos => Icons.chair_outlined,
      Recurso.banheiros => Icons.wc,
      Recurso.bebedouros => Icons.water_drop_outlined,
      Recurso.equipamentosEsportivos => Icons.fitness_center,
      Recurso.estacionamento => Icons.local_parking,
    };

IconData iconeAcessibilidade(RecursoAcessibilidade r) => switch (r) {
      RecursoAcessibilidade.rampas => Icons.accessible_forward,
      RecursoAcessibilidade.caminhosAcessiveis => Icons.accessible,
      RecursoAcessibilidade.banheiroAdaptado => Icons.wc,
      RecursoAcessibilidade.iluminacao => Icons.light_outlined,
    };

/// "PARQUE · JARDIM PRIMAVERA" (sobretítulo dos cards do protótipo).
class Sobretitulo extends StatelessWidget {
  const Sobretitulo(this.area, {super.key});
  final AreaVerde area;

  @override
  Widget build(BuildContext context) => Text(
        '${area.tipo.rotulo} · ${area.bairro}'.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w800,
          color: Cores.terra,
        ),
      );
}

/// Foto do local. Sem foto (ou sem internet), mostra um fundo verde com o
/// ícone do tipo de área.
class FotoArea extends StatelessWidget {
  const FotoArea({
    super.key,
    required this.area,
    this.altura = 170,
    this.indice = 0,
    this.raio = const BorderRadius.vertical(top: Radius.circular(18)),
  });

  final AreaVerde area;
  final double altura;
  final int indice;
  final BorderRadius raio;

  @override
  Widget build(BuildContext context) {
    final fundo = Container(
      height: altura,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7457), Cores.floresta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(iconeTipo(area.tipo), size: altura * 0.35, color: Colors.white70),
    );
    return ClipRRect(
      borderRadius: raio,
      child: area.fotos.length > indice
          ? Image.network(
              area.fotos[indice],
              height: altura,
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: 'Foto de ${area.nome}',
              errorBuilder: (_, _, _) => fundo,
            )
          : Semantics(label: 'Ilustração de ${area.nome}', child: fundo),
    );
  }
}

/// Decodifica a imagem da foto sem derrubar a tela se o base64 vier
/// corrompido (documento editado à mão no console, por exemplo).
Uint8List? bytesDaFoto(Foto f) {
  try {
    return f.bytes;
  } catch (_) {
    return null;
  }
}

/// Foto da comunidade (base64 → bytes).
class ImagemBytes extends StatelessWidget {
  const ImagemBytes(this.bytes, {super.key, this.altura = 160, this.legenda = ''});
  final Uint8List bytes;
  final double altura;
  final String legenda;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          bytes,
          height: altura,
          fit: BoxFit.cover,
          semanticLabel: legenda.isEmpty ? 'Foto enviada pela comunidade' : legenda,
          errorBuilder: (_, _, _) => Container(
            height: altura,
            width: altura,
            color: Cores.areia,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      );
}

/// Selo "Acessível".
class SeloAcessivel extends StatelessWidget {
  const SeloAcessivel({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Cores.folhaClara,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.accessible, size: 16, color: Cores.floresta),
          SizedBox(width: 4),
          Text('Acessível',
              style: TextStyle(fontWeight: FontWeight.w700, color: Cores.floresta)),
        ]),
      );
}

/// Pílula de distância ("650 m") sobre a foto.
class PilulaDistancia extends StatelessWidget {
  const PilulaDistancia(this.metros, {super.key});
  final double metros;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Text(formatarDistancia(metros),
            style: const TextStyle(fontWeight: FontWeight.w800, color: Cores.texto)),
      );
}

/// ★ 4,7 · 212 avaliações
class NotaArea extends StatelessWidget {
  const NotaArea(this.resumo, {super.key, this.mostrarTotal = true});
  final ResumoAvaliacoes resumo;
  final bool mostrarTotal;

  @override
  Widget build(BuildContext context) {
    if (resumo.total == 0) {
      return const Text('Sem avaliações', style: TextStyle(color: Cores.texto2));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, size: 18, color: Cores.estrela),
      const SizedBox(width: 2),
      Text(formatarNota(resumo.media),
          style: const TextStyle(fontWeight: FontWeight.w800, color: Cores.texto)),
      if (mostrarTotal)
        Text(
          ' ${resumo.total} ${resumo.total == 1 ? 'avaliação' : 'avaliações'}',
          style: const TextStyle(color: Cores.texto2),
        ),
    ]);
  }
}

/// Linha de recurso: ícone + nome + estado (Tem / Não tem / Não informado).
/// A cor nunca vem sozinha: sempre há ícone e texto (acessibilidade).
class LinhaDisponibilidade extends StatelessWidget {
  const LinhaDisponibilidade({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final Disponibilidade valor;

  @override
  Widget build(BuildContext context) {
    final (IconData simbolo, Color cor) = switch (valor) {
      Disponibilidade.tem => (Icons.check_circle, Cores.floresta),
      Disponibilidade.naoTem => (Icons.cancel, Cores.terra),
      Disponibilidade.naoInformado => (Icons.help, Cores.naoInformado),
    };
    return Semantics(
      label: '$rotulo: ${valor.rotulo}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icone, color: Cores.texto),
          const SizedBox(width: 12),
          Expanded(child: Text(rotulo, style: const TextStyle(color: Cores.texto))),
          Icon(simbolo, color: cor, size: 20),
          const SizedBox(width: 6),
          Text(valor.rotulo,
              style: TextStyle(color: cor, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/// Legenda dos três estados (RF07).
class LegendaDisponibilidade extends StatelessWidget {
  const LegendaDisponibilidade({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          _ItemLegenda(Icons.check_circle, Cores.floresta, 'Tem'),
          _ItemLegenda(Icons.cancel, Cores.terra, 'Não tem'),
          _ItemLegenda(Icons.help, Cores.naoInformado, 'Ninguém informou ainda'),
        ],
      );
}

class _ItemLegenda extends StatelessWidget {
  const _ItemLegenda(this.icone, this.cor, this.texto);
  final IconData icone;
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icone, size: 16, color: cor),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 13, color: Cores.texto2)),
      ]);
}

/// Faixa "Sem internet" (tratamento de falhas de conexão).
class FaixaOffline extends StatelessWidget {
  const FaixaOffline({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: ConectividadeEstado.instancia,
        builder: (context, _) {
          if (ConectividadeEstado.instancia.online) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            color: Cores.terra,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sem internet. Mostrando dados salvos no aparelho.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          );
        },
      );
}

/// Estado vazio com orientação.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icone, size: 52, color: Cores.floresta),
            const SizedBox(height: 12),
            Text(titulo,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Cores.texto2)),
            if (acao != null) ...[const SizedBox(height: 16), acao!],
          ]),
        ),
      );
}

/// Erro de carregamento com botão "Tentar de novo".
class ErroCarregamento extends StatelessWidget {
  const ErroCarregamento({super.key, required this.mensagem, this.aoTentar});
  final String mensagem;
  final VoidCallback? aoTentar;

  @override
  Widget build(BuildContext context) => EstadoVazio(
        icone: Icons.wifi_off,
        titulo: 'Não foi possível carregar',
        mensagem: mensagem,
        acao: aoTentar == null
            ? null
            : OutlinedButton.icon(
                onPressed: aoTentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
              ),
      );
}

/// Título de seção da página do local ("Atividades", "Estrutura"…).
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, this.acao});
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.headlineSmall)),
          ?acao,
        ]),
      );
}

/// Indicador de carregamento dentro de botão.
class GirandoNoBotao extends StatelessWidget {
  const GirandoNoBotao({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
      );
}

/// Seletor de 1 a 5 estrelas integrado à validação do formulário.
class CampoEstrelas extends FormField<int> {
  CampoEstrelas({
    super.key,
    required String rotulo,
    required int valor,
    required ValueChanged<int> aoMudar,
  }) : super(
          initialValue: valor,
          validator: (_) => valor < 1 ? 'Escolha uma nota para "$rotulo".' : null,
          builder: (estado) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(rotulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Cores.texto)),
                ),
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: '$rotulo: $i de 5',
                    onPressed: () {
                      aoMudar(i);
                      estado.didChange(i);
                    },
                    icon: Icon(
                      i <= valor ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Cores.estrela,
                    ),
                  ),
              ]),
              if (estado.hasError)
                Text(estado.errorText!,
                    style: TextStyle(
                        color: Theme.of(estado.context).colorScheme.error,
                        fontSize: 12)),
            ],
          ),
        );
}
