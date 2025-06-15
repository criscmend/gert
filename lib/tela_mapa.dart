import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MapaDetalhesScreen extends StatefulWidget {
  final String mapaNome;
  final String mapaId;
  final Color corTema;

  const MapaDetalhesScreen({
    super.key,
    required this.mapaNome,
    required this.mapaId,
    required this.corTema,
  });

  @override
  MapaDetalhesScreenState createState() => MapaDetalhesScreenState();
}

class MapaDetalhesScreenState extends State<MapaDetalhesScreen> {
  final TextEditingController _observacaoController = TextEditingController();
  Stream<DocumentSnapshot>? _mapStream;

  @override
  void initState() {
    super.initState();
    _mapStream = FirebaseFirestore.instance.collection('mapasGM').doc(widget.mapaId).snapshots();
  }

  Set<Polygon> _createPolygon(List<LatLng> points) {
    if (points.isEmpty) return {};
    return {
      Polygon(
        polygonId: const PolygonId('mapa_polygon'),
        points: points,
        strokeWidth: 2,
        strokeColor: widget.corTema,
        fillColor: widget.corTema.withOpacity(0.25),
      ),
    };
  }

  Future<void> _atualizarProgressoDoCiclo(String grupoNome, String mapaId) async {
    final firestore = FirebaseFirestore.instance;
    final cicloRef = firestore.collection('ciclos_grupo').doc(grupoNome);
    
    // Otimização: Usa count() para ser mais rápido
    final totalMapasSnapshot = await firestore.collection('mapasGM').where('grupo', isEqualTo: grupoNome).count().get();
    final totalMapas = totalMapasSnapshot.count ?? 0;

    if (totalMapas == 0) return;

    await firestore.runTransaction((transaction) async {
      final cicloDoc = await transaction.get(cicloRef);
      if (!cicloDoc.exists) {
        transaction.set(cicloRef, {'cicloAtual': 1, 'mapasConcluidos': [mapaId]});
      } else {
        final data = cicloDoc.data() as Map<String, dynamic>;
        List<String> mapasConcluidos = List<String>.from(data['mapasConcluidos'] ?? []);
        if (!mapasConcluidos.contains(mapaId)) {
          mapasConcluidos.add(mapaId);
          if (mapasConcluidos.length >= totalMapas) {
            transaction.update(cicloRef, {'cicloAtual': FieldValue.increment(1), 'mapasConcluidos': []});
          } else {
            transaction.update(cicloRef, {'mapasConcluidos': mapasConcluidos});
          }
        }
      }
    });
  }

  Future<void> _showConfirmationDialog(DocumentSnapshot mapDoc, String newStatus) async {
    // ... (código inalterado)
    final responsibleController = TextEditingController();
    final actionText = newStatus == 'iniciado' ? 'iniciar' : 'encerrar';
    final confirmButtonText = newStatus == 'iniciado' ? 'INICIAR' : 'ENCERRAR';
    final confirmButtonColor = newStatus == 'iniciado' ? const Color(0xFF4A8C27) : const Color(0xFFC22626);

    final String? responsibleName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Confirma $actionText esse mapa?',
            textAlign: TextAlign.center,
            style: GoogleFonts.ptSansCaption(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('DIGITE SEU NOME:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: responsibleController,
                decoration: InputDecoration(
                  hintText: 'Responsável',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                autofocus: true,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.black54)),
                    onPressed: () => Navigator.of(dialogContext).pop(null),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(confirmButtonText),
                    onPressed: () {
                      if (responsibleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, informe o nome do responsável.'), backgroundColor: Colors.orange));
                      } else {
                        Navigator.of(dialogContext).pop(responsibleController.text.trim());
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );

    if (responsibleName != null) {
      await _performMapUpdate(mapDoc, newStatus, responsibleName);
    }
  }

  Future<void> _performMapUpdate(DocumentSnapshot mapDoc, String newStatus, String responsibleName) async {
    // ... (código inalterado)
    final dateField = newStatus == 'iniciado' ? 'dataInicio' : 'dataFim';
    try {
      await mapDoc.reference.update({
        'status': newStatus,
        dateField: Timestamp.now(),
        'responsavel': responsibleName,
        'dataUltimaModificacao': Timestamp.now(),
      });

      if (newStatus == 'encerrado') {
        final data = mapDoc.data() as Map<String, dynamic>?;
        final grupoNome = data?['grupo'] as String?;
        if (grupoNome != null) {
          await _atualizarProgressoDoCiclo(grupoNome, mapDoc.id);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao atualizar mapa: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _editarObservacao(DocumentReference mapRef) async {
    // ... (código inalterado)
    final controller = TextEditingController(text: _observacaoController.text);
    final novaObservacao = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Editar Observação',
            textAlign: TextAlign.center,
            style: GoogleFonts.ptSansCaption(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            maxLength: 100, 
            decoration: const InputDecoration(
              hintText: 'Digite a observação...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
             Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.black54)),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.corTema,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('SALVAR'),
                    onPressed: () => Navigator.of(context).pop(controller.text),
                  ),
                ),
              ],
            )
          ]),
    );
    if (novaObservacao != null && novaObservacao != _observacaoController.text) {
      try {
        await mapRef.update({'observacao': novaObservacao, 'dataUltimaModificacao': Timestamp.now()});
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar observação: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      backgroundColor: const Color(0xFFD7D7D7),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _mapStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text('Mapa não encontrado.'));

          final mapDoc = snapshot.data!;
          final data = mapDoc.data() as Map<String, dynamic>;
          _observacaoController.text = data['observacao'] ?? '';
          
          return Column(
            children: [
              _buildHeader(data['mapa'] ?? widget.mapaNome),
              Expanded(child: _buildBodyWithBackground(mapDoc)),
              _buildFooter(mapDoc),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String mapName) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
      width: double.infinity,
      color: widget.corTema,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('Voltar', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
            ])),
        const SizedBox(height: 12),
        Text(mapName, style: GoogleFonts.ptSansCaption(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
  
  Widget _buildBodyWithBackground(DocumentSnapshot mapDoc) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            color: Colors.white.withOpacity(0.85),
            colorBlendMode: BlendMode.dstATop,
          ),
        ),
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBodyContent(mapDoc),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyContent(DocumentSnapshot mapDoc) {
    final data = mapDoc.data() as Map<String, dynamic>;
    final List<dynamic> rawCoords = data['coordenadas'] as List<dynamic>? ?? [];
    final polygonPoints = rawCoords.map((p) => LatLng((p['latitude'] as num).toDouble(), (p['longitude'] as num).toDouble())).toList();
    
    final centerPoint = data['pontoCentral'] as Map<String, dynamic>?;
    final cameraTarget = centerPoint != null ? LatLng((centerPoint['latitude'] as num).toDouble(), (centerPoint['longitude'] as num).toDouble()) : const LatLng(0,0);

    final dataInicio = (data['dataInicio'] as Timestamp?)?.toDate();
    final dataFim = (data['dataFim'] as Timestamp?)?.toDate();
    final format = DateFormat('dd/MM/yy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: cameraTarget, zoom: 15.5),
              polygons: _createPolygon(polygonPoints),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildInfoBlock(label: 'Data de Início', value: dataInicio != null ? format.format(dataInicio) : "-")),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoBlock(label: 'Data de Encerramento', value: dataFim != null ? format.format(dataFim) : "-")),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoBlock(label: 'Último Responsável', value: data['responsavel'] ?? "-"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('OBSERVAÇÃO:', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: widget.corTema),
                    onPressed: () => _editarObservacao(mapDoc.reference),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _observacaoController.text.isEmpty ? 'Nenhuma observação.' : _observacaoController.text,
                style: TextStyle(color: _observacaoController.text.isEmpty ? Colors.black45 : Colors.black87),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_observacaoController.text.length}/100',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFooter(DocumentSnapshot mapDoc) {
    final data = mapDoc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'aguardando';
    final canStart = status == 'aguardando' || status == 'encerrado';
    final canEnd = status == 'iniciado' || status == 'ativo';

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      color: widget.corTema,
      child: Row(children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canStart ? const Color(0xFF4A8C27) : Colors.grey.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: canStart ? () => _showConfirmationDialog(mapDoc, 'iniciado') : null,
            child: const Text('INICIAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canEnd ? const Color(0xFFC22626) : Colors.grey.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: canEnd ? () => _showConfirmationDialog(mapDoc, 'encerrado') : null,
            child: const Text('ENCERRAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}