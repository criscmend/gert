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
  late GoogleMapController mapController;
  final Set<Polygon> _polygons = {};

  // Função para obter as coordenadas específicas do mapa para cada grupo com marcador centralizado
  LatLng _getMapCoordinates(String grupo) {
    switch (grupo) {
      case 'GRUPO 1':
        return const LatLng(-3.7630, -38.5390);
      case 'GRUPO 2':
        return const LatLng(-3.7660, -38.5430); 
      case 'GRUPO 3':
        return const LatLng(-3.7565, -38.5280);
      case 'GRUPO 4':
        return const LatLng(-3.7710, -38.5300);
      default:
        return const LatLng(-3.7327, -38.5269); 
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPolygonForGroup(widget.nomeGrupo);
  }

  // Função para carregar o polígono com base no grupo
  void _loadPolygonForGroup(String grupo) {
    List<LatLng> polygonCoords = [];

    if (grupo == 'GRUPO 1') {
      polygonCoords = [
        const LatLng(-3.7567654, -38.5408088),
        const LatLng(-3.7600575, -38.5423923),
        const LatLng(-3.7617944, -38.5429417),
        const LatLng(-3.7627794, -38.5437678),
        const LatLng(-3.7636786, -38.5407744),
        const LatLng(-3.7678967, -38.5420404),
        const LatLng(-3.769267, -38.5380386),
        const LatLng(-3.7586469, -38.5348521),
        const LatLng(-3.7567654, -38.5408088), // Ponto final igual ao inicial para fechar o polígono
      ];
    } else if (grupo == 'GRUPO 2') {
      polygonCoords = [
        const LatLng(-3.7724635, -38.5390894),
        const LatLng(-3.7692947, -38.5380702),
        const LatLng(-3.7685346, -38.5400764),
        const LatLng(-3.7679136, -38.5421149),
        const LatLng(-3.7636849, -38.5408382),
        const LatLng(-3.7627856, -38.5438101),
        const LatLng(-3.7621433, -38.5458486),
        const LatLng(-3.7618756, -38.5462884),
        const LatLng(-3.7660616, -38.5498075),
        const LatLng(-3.767737, -38.5478173),
        const LatLng(-3.7679029, -38.5475866),
        const LatLng(-3.768465, -38.5472111),
        const LatLng(-3.769664, -38.5479568),
        const LatLng(-3.7700976, -38.5471736),
        const LatLng(-3.7702742, -38.5470663),
        const LatLng(-3.7714197, -38.5433005),
        const LatLng(-3.7724635, -38.5390894),
      ];
    } else if (grupo == 'GRUPO 3') {
      polygonCoords = [
        const LatLng(-3.76073, -38.5256421),
        const LatLng(-3.7615009, -38.5190224),
        const LatLng(-3.7591242, -38.5193442),
        const LatLng(-3.7585247, -38.5196017),
        const LatLng(-3.7580108, -38.5200845),
        const LatLng(-3.7563407, -38.5222625),
        const LatLng(-3.7561587, -38.5225414),
        const LatLng(-3.7562657, -38.5229277),
        const LatLng(-3.7564691, -38.5233783),
        const LatLng(-3.7564584, -38.5239684),
        const LatLng(-3.7561908, -38.5243439),
        const LatLng(-3.7558054, -38.5243653),
        const LatLng(-3.7553986, -38.5253846),
        const LatLng(-3.7564263, -38.5277449),
        const LatLng(-3.7563728, -38.5285603),
        const LatLng(-3.752144, -38.5327982),
        const LatLng(-3.7514909, -38.5335707),
        const LatLng(-3.7511805, -38.5357594),
        const LatLng(-3.7505916, -38.5368323),
        const LatLng(-3.7601733, -38.5398041),
        const LatLng(-3.7607193, -38.5385918),
        const LatLng(-3.761533, -38.5373902),
        const LatLng(-3.7616507, -38.537358),
        const LatLng(-3.7621111, -38.5358452),
        const LatLng(-3.7625179, -38.5359739),
        const LatLng(-3.7634172, -38.533163),
        const LatLng(-3.7642736, -38.5301375),
        const LatLng(-3.7663934, -38.5310172),
        const LatLng(-3.7671642, -38.5291611),
        const LatLng(-3.7673676, -38.5280882),
        const LatLng(-3.7622074, -38.5272085),
        const LatLng(-3.7623038, -38.5257815),
        const LatLng(-3.76073, -38.5256421),
      ];
    } else if (grupo == 'GRUPO 4') {
      polygonCoords = [
        const LatLng(-3.7672581, -38.5285149),
        const LatLng(-3.767226, -38.5288582),
        const LatLng(-3.7671618, -38.5291479),
        const LatLng(-3.7665837, -38.5306499),
        const LatLng(-3.7664017, -38.531004),
        const LatLng(-3.7643141, -38.5301457),
        const LatLng(-3.7640357, -38.5311864),
        const LatLng(-3.7629973, -38.5342977),
        const LatLng(-3.7625155, -38.5359714),
        const LatLng(-3.7709194, -38.5385464),
        const LatLng(-3.7721292, -38.5388897),
        const LatLng(-3.7725574, -38.5387609),
        const LatLng(-3.7727501, -38.5383425),
        const LatLng(-3.7757048, -38.5269592),
        const LatLng(-3.7719365, -38.5271202),
        const LatLng(-3.7703842, -38.5274635),
        const LatLng(-3.7672581, -38.5285149),
      ];
    }

    setState(() {
      _polygons.clear();
      if (polygonCoords.isNotEmpty) {
        _polygons.add(
          Polygon(
            polygonId: PolygonId('polygon_$grupo'),
            points: polygonCoords,
            strokeWidth: 2,
            strokeColor: Colors.blue.shade700,
            fillColor: Colors.blue.shade100.withOpacity(0.5),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCoordinates = _getMapCoordinates(widget.nomeGrupo);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeGrupo),
        backgroundColor: widget.corTema,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirigente: ${widget.dirigente}',
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            Text(
              'Ajudante: ${widget.ajudante}',
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            const SizedBox(height: 16.0),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey, width: 1.0),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: mapCoordinates,
                  zoom: 14.0, // Ajuste o zoom conforme necessário
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                markers: {
                  Marker(
                    markerId: MarkerId('grupo_marker_${widget.nomeGrupo}'),
                    position: mapCoordinates,
                    infoWindow: InfoWindow(
                      title: 'Área do ${widget.nomeGrupo}',
                      snippet: 'Mapa centrado neste local.',
                    ),
                  ),
                },
                polygons: _polygons,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),

            const SizedBox(height: 16.0),
            const Text(
              'STATUS DO TERRITÓRIO: 82%',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const LinearProgressIndicator(
              value: 0.82,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'ÚLTIMOS MAPAS',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DataTable(
              columns: const [
                DataColumn(label: Text('MAPA')),
                DataColumn(label: Text('DATA')),
                DataColumn(label: Text('RESPONSÁVEL')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('MAPA 1')),
                  DataCell(Text('01/01/2025')),
                  DataCell(Text('JOÃO')),
                ]),
                DataRow(cells: [
                  DataCell(Text('MAPA 2')),
                  DataCell(Text('02/01/2025')),
                  DataCell(Text('JOSÉ')),
                ]),
                DataRow(cells: [
                  DataCell(Text('MAPA 3')),
                  DataCell(Text('03/01/2025')),
                  DataCell(Text('CARLOS')),
                ]),
              ],
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaGrupoScreen(
                            nomeGrupo: widget.nomeGrupo,
                            nomeDirigente: widget.dirigente,
                            nomeAjudante: widget.ajudante,
                            corTema: widget.corTema,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.corTema,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      'IR PARA MAPAS',
                      style: GoogleFonts.rajdhani(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}