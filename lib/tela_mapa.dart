import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaDetalhesScreen extends StatefulWidget {
  final String mapaNome;
  final String mapaId;
  // O construtor agora espera a cor do tema para estilizar a tela.
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

  Future<void> _showConfirmationDialog(DocumentSnapshot mapDoc, String newStatus) async {
    final responsibleController = TextEditingController();
    final actionText = newStatus == 'iniciado' ? 'Iniciar' : 'Encerrar';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirmar Ação', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja realmente $actionText este mapa?'),
              const SizedBox(height: 16),
              TextField(
                controller: responsibleController,
                decoration: const InputDecoration(labelText: 'Nome do Responsável', border: OutlineInputBorder()),
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(child: const Text('CANCELAR'), onPressed: () => Navigator.of(dialogContext).pop(false)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: newStatus == 'iniciado' ? const Color(0xFF4A8C27) : const Color(0xFFC22626)),
              child: Text(actionText.toUpperCase(), style: const TextStyle(color: Colors.white)),
              onPressed: () {
                if (responsibleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, informe o nome do responsável.'), backgroundColor: Colors.orange));
                } else {
                  Navigator.of(dialogContext).pop(true);
                }
              },
            ),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      final responsibleName = responsibleController.text.trim();
      final dateField = newStatus == 'iniciado' ? 'dataInicio' : 'dataFim';
      
      try {
        await mapDoc.reference.update({
          'status': newStatus, dateField: Timestamp.now(), 'responsavel': responsibleName,
        });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mapa $actionText com sucesso!'), backgroundColor: Colors.green));
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar mapa: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _editarObservacao(DocumentReference mapRef) async {
    final novaObservacao = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _observacaoController.text);
        return AlertDialog(
          title: const Text('Editar Observação'),
          content: TextField(controller: controller, maxLines: 3, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Salvar')),
          ],
        );
      },
    );

    if (novaObservacao != null && novaObservacao != _observacaoController.text) {
      try {
        await mapRef.update({'observacao': novaObservacao});
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Observação salva!'), backgroundColor: Colors.green));
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar observação: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D7D7),
      // Uso de StreamBuilder para ouvir as atualizações do mapa em tempo real.
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('mapasGM').doc(widget.mapaId).snapshots(),
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
              _buildBody(data),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('Voltar', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 12),
          Text(mapName, style: GoogleFonts.rajdhani(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
  
  Widget _buildBody(Map<String, dynamic> data) {
    final List<dynamic> rawCoords = data['coordenadas'] as List<dynamic>? ?? [];
    final polygonPoints = rawCoords.map((p) => LatLng((p['latitude'] as num).toDouble(), (p['longitude'] as num).toDouble())).toList();
    
    final centerPoint = data['pontoCentral'] as Map<String, dynamic>?;
    final cameraTarget = centerPoint != null ? LatLng((centerPoint['latitude'] as num).toDouble(), (centerPoint['longitude'] as num).toDouble()) : const LatLng(0,0);

    final dataInicio = (data['dataInicio'] as Timestamp?)?.toDate();
    final dataFim = (data['dataFim'] as Timestamp?)?.toDate();
    final format = DateFormat('dd/MM/yy');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: cameraTarget, zoom: 15.5),
                  polygons: _createPolygon(polygonPoints),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                   gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Iniciado: ${dataInicio != null ? format.format(dataInicio) : "-"}'),
                    Text('Encerrado: ${dataFim != null ? format.format(dataFim) : "-"}'),
                    Text('Responsável: ${data['responsavel'] ?? "-"}'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Observação:', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _editarObservacao(data['reference'] as DocumentReference))
                      ],
                    ),
                    Text(_observacaoController.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? const Color(0xFF4A8C27) : Colors.grey.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: canStart ? () => _showConfirmationDialog(mapDoc, 'iniciado') : null,
              child: const Text('INICIAR'),
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
              child: const Text('ENCERRAR'),
            ),
          ),
        ],
      ),
    );
  }
}