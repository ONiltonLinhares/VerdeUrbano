import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/tema.dart';
import '../estado/localizacao_estado.dart';
import '../models/area_verde.dart';
import 'componentes.dart';

/// Card do feed (protótipo): foto com distância, "PARQUE · BAIRRO", nome,
/// nota, horário, atividades e selo "Acessível".
class AreaCard extends StatelessWidget {
  const AreaCard({super.key, required this.area, required this.aoTocar});

  final AreaVerde area;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final dist = LocalizacaoEstado.instancia.distanciaAte(area);
    final aberto = area.estaAberta(DateTime.now());

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            FotoArea(area: area),
            if (dist != null)
              Positioned(left: 12, top: 12, child: PilulaDistancia(dist)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Sobretitulo(area),
              const SizedBox(height: 4),
              Text(area.nome, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  NotaArea(area.resumo),
                  Text(
                    situacaoHorario(area.horario, DateTime.now()),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: aberto ? Cores.floresta : Cores.terra,
                    ),
                  ),
                ],
              ),
              if (area.atividades.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  area.atividades.map((a) => a.rotulo).join(' · '),
                  style: const TextStyle(color: Cores.texto2),
                ),
              ],
              if (area.isAcessivel) ...[
                const SizedBox(height: 10),
                const SeloAcessivel(),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
