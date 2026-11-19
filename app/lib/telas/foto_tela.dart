import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../core/navegacao.dart';
import '../core/validadores.dart';
import '../data/fotos_repositorio.dart';
import '../estado/sessao.dart';
import '../models/foto.dart';
import '../widgets/componentes.dart';

/// Foto da comunidade (CRUD 4): enviar, ver, editar a legenda e excluir.
/// [foto] nulo = enviar nova.
class FotoTela extends StatefulWidget {
  const FotoTela({super.key, required this.areaId, this.foto});
  final String areaId;
  final Foto? foto;

  @override
  State<FotoTela> createState() => _FotoTelaState();
}

class _FotoTelaState extends State<FotoTela> {
  final _legenda = TextEditingController();
  Uint8List? _bytes;
  bool _salvando = false;

  bool get _nova => widget.foto == null;
  bool get _dono => widget.foto?.podeEditar(Sessao.instancia.uid) ?? true;

  @override
  void initState() {
    super.initState();
    _legenda.text = widget.foto?.legenda ?? '';
    _bytes = widget.foto == null ? null : bytesDaFoto(widget.foto!);
  }

  @override
  void dispose() {
    _legenda.dispose();
    super.dispose();
  }

  /// A foto é reduzida e comprimida já na escolha, para caber no limite de
  /// ~700 KB do documento do Firestore (ver Foto.tamanhoMaximoBytes).
  Future<void> _escolher(ImageSource origem) async {
    try {
      final arquivo = await ImagePicker().pickImage(
        source: origem,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 65,
      );
      if (arquivo == null) return;
      final bytes = await arquivo.readAsBytes();
      if (bytes.length > Foto.tamanhoMaximoBytes) {
        if (mounted) {
          avisar(context, 'A foto ficou grande demais mesmo comprimida. Tente outra.');
        }
        return;
      }
      setState(() => _bytes = bytes);
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível abrir a câmera ou a galeria.');
    }
  }

  Future<void> _salvar() async {
    final erro = Validadores.texto(_legenda.text, max: 200);
    if (erro != null) {
      avisar(context, erro);
      return;
    }
    setState(() => _salvando = true);
    try {
      if (_nova) {
        final sessao = Sessao.instancia;
        await FotosRepositorio.instancia.enviar(
          areaId: widget.areaId,
          autorId: sessao.uid!,
          autorNome: sessao.nomePublico,
          bytes: _bytes ?? Uint8List(0),
          legenda: _legenda.text,
        );
      } else {
        await FotosRepositorio.instancia.atualizarLegenda(widget.foto!, _legenda.text);
      }
      if (!mounted) return;
      avisar(context, _nova ? 'Foto enviada. Obrigado!' : 'Legenda atualizada');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    final ok = await confirmar(context, titulo: 'Excluir esta foto?');
    if (!ok || !mounted) return;
    try {
      await FotosRepositorio.instancia.excluir(widget.foto!);
      if (!mounted) return;
      avisar(context, 'Foto excluída');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) avisar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final podeExcluir = !_nova && (_dono || Sessao.instancia.isAdmin);
    return Scaffold(
      appBar: AppBar(
        title: Text(_nova ? 'Enviar foto' : 'Foto da comunidade'),
        actions: [
          if (podeExcluir)
            IconButton(
              tooltip: 'Excluir foto',
              onPressed: _excluir,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (_bytes != null)
          ImagemBytes(_bytes!, altura: 280, legenda: _legenda.text)
        else
          Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD6DCD8)),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined, size: 48),
          ),
        if (!_nova)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Por ${widget.foto!.autorNome} · ${formatarData(widget.foto!.criadoEm)}',
              style: tema.textTheme.bodyMedium,
            ),
          ),
        if (_nova) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _escolher(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Câmera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _escolher(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
            ),
          ]),
        ],
        const SizedBox(height: 16),
        if (_dono)
          TextField(
            controller: _legenda,
            maxLength: 200,
            decoration: const InputDecoration(labelText: 'Legenda (opcional)'),
          )
        else if (_legenda.text.isNotEmpty)
          Text(_legenda.text, style: tema.textTheme.bodyLarge),
        if (_dono) ...[
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _salvando || (_nova && _bytes == null) ? null : _salvar,
            child: _salvando
                ? const GirandoNoBotao()
                : Text(_nova ? 'Enviar foto' : 'Salvar legenda'),
          ),
          const SizedBox(height: 8),
          Text('A foto fica pública e aparece com seu nome. Evite mostrar o rosto de outras pessoas.',
              style: tema.textTheme.bodyMedium),
        ],
      ]),
    );
  }
}
