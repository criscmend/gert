import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'lista_mapas.dart'; 

class TelaGrupo extends StatefulWidget {
  final String nomeGrupo;
  final String dirigente;
  final String ajudante;
  final Color corTema;

  const TelaGrupo({
    super.key,
    required this.nomeGrupo,
    required this.dirigente,
    required this.ajudante,
    required this.corTema,
  });

  @override
  State<TelaGrupo> createState() => _TelaGrupoState();
}

class _TelaGrupoState extends State<TelaGrupo> {
  // A lógica de polígonos e coordenadas permanece a mesma.
  final Set<Polygon> _polygons = {};

  LatLng _getMapCoordinates(String grupo) {
    switch (grupo) {
      case 'GRUPO 1': return const LatLng(-3.7630, -38.5390);
      case 'GRUPO 2': return const LatLng(-3.7660, -38.5430);
      case 'GRUPO 3': return const LatLng(-3.7565, -38.5280);
      case 'GRUPO 4': return const LatLng(-3.7710, -38.5300);
      default: return const LatLng(-3.7327, -38.5269);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPolygonForGroup(widget.nomeGrupo);
  }

  void _loadPolygonForGroup(String grupo) {
    List<LatLng> polygonCoords = [];
    if (grupo == 'GRUPO 1') {
      polygonCoords = [
        const LatLng(-3.7567654, -38.5408088), const LatLng(-3.7600575, -38.5423923), const LatLng(-3.7617944, -38.5429417), const LatLng(-3.7627794, -38.5437678), const LatLng(-3.7636786, -38.5407744), const LatLng(-3.7678967, -38.5420404), const LatLng(-3.769267, -38.5380386), const LatLng(-3.7586469, -38.5348521), const LatLng(-3.7567654, -38.5408088),
      ];
    }
    // Adicione a lógica para outros grupos aqui se necessário...
    setState(() {
      _polygons.clear();
      if (polygonCoords.isNotEmpty) {
        _polygons.add(Polygon(
          polygonId: PolygonId('polygon_$grupo'),
          points: polygonCoords,
          strokeWidth: 2,
          strokeColor: widget.corTema,
          fillColor: widget.corTema.withOpacity(0.25),
        ));
      }
    });
  }

  // WIDGET NOVO: Cria uma linha da tabela de histórico para evitar repetição.
  Widget _buildHistoryRow(String map, String date, String responsible, {bool isHeader = false}) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      color: isHeader ? Colors.grey.shade300 : Colors.transparent,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(map, style: style)),
          Expanded(flex: 2, child: Text(date, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text(responsible, style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D7D7),
      body: Column(
        children: [
          // CABEÇALHO
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 24),
            color: widget.corTema,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('Voltar', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(widget.nomeGrupo, style: GoogleFonts.rajdhani(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Dirigente: ${widget.dirigente}', style: GoogleFonts.lato(fontSize: 15, color: Colors.white.withOpacity(0.9))),
                Text('Ajudante: ${widget.ajudante}', style: GoogleFonts.lato(fontSize: 15, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          
          // CORPO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: _getMapCoordinates(widget.nomeGrupo), zoom: 14.5),
                        polygons: _polygons,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('STATUS DO TERRITÓRIO: 82%', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: 0.82,
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.corTema),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 16),
                  // ALTERAÇÃO: A DataTable foi substituída por um layout flexível com Column e Rows.
                  // Isso resolve o problema de overflow em telas menores.
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildHistoryRow('ÚLTIMOS MAPAS', 'DATA', 'RESPONSÁVEL', isHeader: true),
                        const Divider(height: 1, color: Colors.grey),
                        _buildHistoryRow('MAPA 1', '01/01/25', 'JOÃO'),
                        _buildHistoryRow('MAPA 2', '02/01/25', 'JOSÉ'),
                        _buildHistoryRow('MAPA 3', '03/01/25', 'CARLOS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RODAPÉ
          Container(
            width: double.infinity,
            color: widget.corTema,
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ListaGrupoScreen(
                  nomeGrupo: widget.nomeGrupo,
                  nomeDirigente: widget.dirigente,
                  nomeAjudante: widget.ajudante,
                  corTema: widget.corTema,
                )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Text('IR PARA MAPAS', style: GoogleFonts.rajdhani(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}