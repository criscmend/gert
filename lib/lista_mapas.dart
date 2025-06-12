import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'dart:io';
import 'tela_mapa.dart'; 

class ListaGrupoScreen extends StatefulWidget {
  final String nomeGrupo;
  final String nomeDirigente;
  final String nomeAjudante;
  final Color corTema;

  const ListaGrupoScreen({
    super.key,
    required this.nomeGrupo,
    required this.nomeDirigente,
    required this.nomeAjudante,
    required this.corTema,
  });

  @override
  ListaGrupoScreenState createState() => ListaGrupoScreenState();
}

class ListaGrupoScreenState extends State<ListaGrupoScreen> {
  String filtroOrdenacao = 'status';
  String buscaNome = '';
  String? _expandedItemId;

  Future<void> _selecionarArquivoMapa() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Selecionar arquivo KML ou CSV'),
                onTap: () async {
                  Navigator.pop(bc);
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['kml', 'csv'],
                  );

                  if (result != null && result.files.single.path != null) {
                    PlatformFile file = result.files.single;
                    File selectedFile = File(file.path!);
                    String fileContent = await selectedFile.readAsString(encoding: utf8);
                    _processarEcadastrarMapa(file.name, file.extension ?? '', fileContent);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(bc),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processarEcadastrarMapa(String fileName, String fileExtension, String fileContent) async {
    List<Map<String, double>> coordinates = [];
    String mapaNome = fileName.split('.').first;
    try {
      if (fileExtension.toLowerCase() == 'csv') {
        final csvList = const CsvToListConverter().convert(fileContent);
        for (var row in csvList) {
          if (row.length >= 2) {
            try {
              coordinates.add({'latitude': double.parse(row[0].toString()), 'longitude': double.parse(row[1].toString())});
            } catch (e) {/* Ignora erro */}
          }
        }
      } else if (fileExtension.toLowerCase() == 'kml') {
        final document = XmlDocument.parse(fileContent);
        final coordinatesElements = document.findAllElements('coordinates');
        for (var element in coordinatesElements) {
          final points = element.text.trim().split(' ');
          for (var point in points) {
            final parts = point.split(',');
            if (parts.length >= 2) {
              try {
                coordinates.add({'latitude': double.parse(parts[1].toString()), 'longitude': double.parse(parts[0].toString())});
              } catch (e) {/* Ignora erro */}
            }
          }
        }
        final nameElement = document.findAllElements('name').firstWhereOrNull((e) => e.parent is XmlElement && ((e.parent as XmlElement).name.local == 'Document' || (e.parent as XmlElement).name.local == 'Placemark'));
        if (nameElement != null) mapaNome = nameElement.text.trim();
      }

      if (coordinates.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma coordenada válida.')));
        return;
      }

      double totalLat = 0, totalLon = 0;
      for (var coord in coordinates) {
        totalLat += coord['latitude']!;
        totalLon += coord['longitude']!;
      }
      final pontoCentral = {'latitude': totalLat / coordinates.length, 'longitude': totalLon / coordinates.length};

      await FirebaseFirestore.instance.collection('mapasGM').add({
        'mapa': mapaNome, 'grupo': widget.nomeGrupo, 'coordenadas': coordinates, 'status': 'aguardando',
        'dataInicio': null, 'dataFim': null, 'responsavel': null, 'pontoCentral': pontoCentral,
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mapa "$mapaNome" cadastrado!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D7D7),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilterBar(),
          // O Expanded aqui é a chave para resolver o problema da tela em branco.
          // Ele diz ao StreamBuilder para ocupar todo o espaço vertical restante.
          Expanded(
            child: _buildMapList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
      color: widget.corTema,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
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
                Text(widget.nomeGrupo, style: GoogleFonts.rajdhani(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  'Dirigente: ${widget.nomeDirigente} | Ajudante: ${widget.nomeAjudante}',
                  style: GoogleFonts.lato(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
            onPressed: _selecionarArquivoMapa,
            tooltip: 'Adicionar Mapa',
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => buscaNome = value),
              decoration: InputDecoration(
                hintText: 'Procurar por nome...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
            tooltip: 'Ordenar',
            onPressed: () => _mostrarOpcoesOrdenacao(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('mapasGM').where('grupo', isEqualTo: widget.nomeGrupo).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Nenhum mapa cadastrado.'));

        var documentos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['mapa'] as String? ?? '').toLowerCase().contains(buscaNome.toLowerCase());
        }).toList();
        
        if (documentos.isEmpty) return const Center(child: Text('Nenhum mapa encontrado com esse nome.'));

        documentos.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data()as Map<String, dynamic>;
          final statusA = dataA['status']?.toString() ?? 'z';
          final statusB = dataB['status']?.toString() ?? 'z';
          final prioridadeA = (statusA == 'iniciado' || statusA == 'ativo') ? 0 : 1;
          final prioridadeB = (statusB == 'iniciado' || statusB == 'ativo') ? 0 : 1;
          if (prioridadeA != prioridadeB) return prioridadeA.compareTo(prioridadeB);
          switch (filtroOrdenacao) {
            case 'nome': return (dataA['mapa'] as String? ?? '').compareTo(dataB['mapa'] as String? ?? '');
            case 'dataInicio': return (dataB['dataInicio'] as Timestamp? ?? Timestamp(0, 0)).compareTo(dataA['dataInicio'] as Timestamp? ?? Timestamp(0, 0));
            case 'dataFim': return (dataB['dataFim'] as Timestamp? ?? Timestamp(0, 0)).compareTo(dataA['dataFim'] as Timestamp? ?? Timestamp(0, 0));
            default: return (dataA['mapa'] as String? ?? '').compareTo(dataB['mapa'] as String? ?? '');
          }
        });
        
        return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: documentos.length,
            itemBuilder: (context, index) {
                final doc = documentos[index];
                final data = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final isExpanded = _expandedItemId == docId;
                final status = data['status']?.toString() ?? '';
                final isStartedNotFinished = (status == 'iniciado' || status == 'ativo');
                final dataInicio = (data['dataInicio'] as Timestamp?)?.toDate();
                final dataFim = (data['dataFim'] as Timestamp?)?.toDate();
                
                return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: isStartedNotFinished ? Border(left: BorderSide(color: widget.corTema, width: 6)) : null,
                        ),
                        child: ExpansionTile(
                            key: ValueKey(docId),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanding) => setState(() => _expandedItemId = expanding ? docId : null),
                            leading: Icon(Icons.map_outlined, color: widget.corTema),
                            title: Text(data['mapa'] ?? 'Mapa sem nome', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                            children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                        Text('Data Inicial: ${dataInicio != null ? "${dataInicio.day}/${dataInicio.month}/${dataInicio.year}" : "-"}'),
                                        Text('Data Encerramento: ${dataFim != null ? "${dataFim.day}/${dataFim.month}/${dataFim.year}" : "-"}'),
                                        Text('Último Responsável: ${data['responsavel'] ?? "-"}'),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: widget.corTema, foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => MapaDetalhesScreen(
                                                    mapaNome: data['mapa'] ?? '',
                                                    mapaId: docId,
                                                    corTema: widget.corTema,
                                                )));
                                            },
                                            child: const Text('ACESSAR MAPA'),
                                        ),
                                    ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                );
            },
        );
      },
    );
  }

  void _mostrarOpcoesOrdenacao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.all(16.0), child: Text('Ordenar Por', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ListTile(title: const Text('Status (Ativos Primeiro)'), onTap: () => setState(() { filtroOrdenacao = 'status'; Navigator.pop(context); })),
              ListTile(title: const Text('Nome'), onTap: () => setState(() { filtroOrdenacao = 'nome'; Navigator.pop(context); })),
              ListTile(title: const Text('Data de Início'), onTap: () => setState(() { filtroOrdenacao = 'dataInicio'; Navigator.pop(context); })),
              ListTile(title: const Text('Data de Encerramento'), onTap: () => setState(() { filtroOrdenacao = 'dataFim'; Navigator.pop(context); })),
            ],
          ),
        );
      },
    );
  }
}