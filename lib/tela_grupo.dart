import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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
  final Set<Polygon> _polygons = {};
  int _totalMapas = 0;

  @override
  void initState() {
    super.initState();
    _loadPolygonForGroup(widget.nomeGrupo);
    _fetchTotalMapas(); 
  }

  Future<void> _fetchTotalMapas() async {
    // Otimização: .count() é mais rápido e eficiente que .get() para apenas contar.
    final snapshot = await FirebaseFirestore.instance
        .collection('mapasGM')
        .where('grupo', isEqualTo: widget.nomeGrupo)
        .count()
        .get();
    if (mounted) {
      setState(() {
        _totalMapas = snapshot.count ?? 0;
      });
    }
  }

  LatLng _getMapCoordinates(String grupo) {
    switch (grupo) {
      case 'GRUPO 1': return const LatLng(-3.7630, -38.5390);
      case 'GRUPO 2': return const LatLng(-3.7660, -38.5430);
      case 'GRUPO 3': return const LatLng(-3.7565, -38.5280);
      case 'GRUPO 4': return const LatLng(-3.7710, -38.5300);
      default: return const LatLng(-3.7327, -38.5269);
    }
  }

  void _loadPolygonForGroup(String grupo) {
    List<LatLng> polygonCoords = [];
    if (grupo == 'GRUPO 1') {
      polygonCoords = [
        const LatLng(-3.7567654, -38.5408088), const LatLng(-3.7600575, -38.5423923), const LatLng(-3.7617944, -38.5429417), const LatLng(-3.7627794, -38.5437678), const LatLng(-3.7636786, -38.5407744), const LatLng(-3.7678967, -38.5420404), const LatLng(-3.769267, -38.5380386), const LatLng(-3.7586469, -38.5348521), const LatLng(-3.7567654, -38.5408088),
      ];
    }
    setState(() {
      _polygons.clear();
      if (polygonCoords.isNotEmpty) {
        _polygons.add(Polygon(
          polygonId: const PolygonId('polygon_grupo'),
          points: polygonCoords,
          strokeWidth: 2,
          strokeColor: widget.corTema,
          fillColor: widget.corTema.withOpacity(0.25),
        ));
      }
    });
  }

  Widget _buildHistoryRow(String map, String date, String responsible, {bool isHeader = false}) {
    final style = TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 15);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      color: isHeader ? Colors.grey.shade300 : Colors.transparent,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(map, style: style, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(date, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text(responsible, style: style, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildRecentMapsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('mapasGM').where('grupo', isEqualTo: widget.nomeGrupo).orderBy('dataUltimaModificacao', descending: true).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(children: [
            _buildHistoryRow('MAPA', 'DATA', 'RESPONSÁVEL', isHeader: true),
            const Divider(height: 1, color: Colors.grey),
            const Padding(padding: EdgeInsets.all(16.0), child: Text('Nenhuma movimentação recente.')),
          ]);
        }
        final maps = snapshot.data!.docs;
        return Column(children: [
          _buildHistoryRow('MAPA', 'DATA', 'RESPONSÁVEL', isHeader: true),
          const Divider(height: 1, color: Colors.grey),
          ...maps.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['dataUltimaModificacao'] as Timestamp?)?.toDate();
            final dateFormatted = date != null ? DateFormat('dd/MM/yy').format(date) : '-';
            return _buildHistoryRow(data['mapa'] ?? 'N/A', dateFormatted, data['responsavel'] ?? 'N/A');
          }).toList(),
        ]);
      },
    );
  }
  
  Widget _buildProgressBar() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('ciclos_grupo').doc(widget.nomeGrupo).snapshots(),
      builder: (context, cicloSnapshot) {
        if (cicloSnapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 42); 
        }
        
        final cicloData = cicloSnapshot.data?.data() as Map<String, dynamic>?;
        final mapasConcluidos = (cicloData?['mapasConcluidos'] as List<dynamic>?)?.length ?? 0;
        final cicloAtual = cicloData?['cicloAtual'] as int? ?? 1;
        final double progresso = (_totalMapas > 0) ? (mapasConcluidos / _totalMapas) : 0;
            
        return _buildProgressBarUI(progresso, cicloAtual);
      },
    );
  }

  Widget _buildProgressBarUI(double progresso, int ciclo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'STATUS DO TERRITÓRIO: ${(progresso * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: progresso,
          backgroundColor: Colors.grey.shade400,
          valueColor: AlwaysStoppedAnimation<Color>(widget.corTema),
          minHeight: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D7D7),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 24),
            color: widget.corTema,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(onTap: () => Navigator.of(context).pop(), child: Row(children: [
                  const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text('Voltar', style: GoogleFonts.lato(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ])),
                const SizedBox(height: 20),
                Text(widget.nomeGrupo, style: GoogleFonts.ptSansCaption(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Dirigente: ${widget.dirigente}', style: GoogleFonts.lato(fontSize: 15, color: Colors.white.withOpacity(0.9))),
                Text('Ajudante: ${widget.ajudante}', style: GoogleFonts.lato(fontSize: 15, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                    'ÚLTIMOS MAPAS TRABALHADOS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRecentMapsList(),
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: widget.corTema,
            padding: EdgeInsets.fromLTRB(40, 20, 40, MediaQuery.of(context).padding.bottom + 20),
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
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), 
              ),
              child: Text('IR PARA MAPAS', style: GoogleFonts.ptSansCaption(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}