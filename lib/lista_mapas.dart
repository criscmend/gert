import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'dart:io';

import 'tela_mapa.dart'; // Certifique-se de que este caminho está correto

class ListaGrupoScreen extends StatefulWidget {
  final String nomeGrupo;
  final String nomeDirigente;
  final String nomeAjudante;
  final Color corTema;

  const ListaGrupoScreen({
    Key? key,
    required this.nomeGrupo,
    required this.nomeDirigente,
    required this.nomeAjudante,
    required this.corTema,
  }) : super(key: key);

  @override
  ListaGrupoScreenState createState() => ListaGrupoScreenState();
}

class ListaGrupoScreenState extends State<ListaGrupoScreen> {
  String filtroOrdenacao = 'status';
  String buscaNome = '';
  List<String> expandedItemIds = [];

  // Função para selecionar arquivo KML ou CSV e fazer o upload
  Future<void> _selecionarArquivoMapa() async {
    print('DEBUG: Botão "+" pressionado, abrindo bottom sheet.');
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
                  print('DEBUG: "Selecionar arquivo" ListTile clicado.');
                  Navigator.pop(bc);
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['kml', 'csv'],
                  );

                  if (result != null && result.files.single.path != null) {
                    print('DEBUG: Arquivo selecionado com sucesso. Chamando _processarEcadastrarMapa.');
                    PlatformFile file = result.files.single;
                    String fileName = file.name;
                    String fileExtension = file.extension ?? '';

                    File selectedFile = File(file.path!);
                    String fileContent = await selectedFile.readAsString(encoding: utf8);

                    _processarEcadastrarMapa(fileName, fileExtension, fileContent);
                  } else {
                    print('DEBUG: Nenhum arquivo selecionado ou erro na seleção (file.path é nulo).');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () {
                  print('DEBUG: Botão "Cancelar" clicado no bottom sheet.');
                  Navigator.pop(bc);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Função para processar o arquivo e cadastrar no Firestore
  Future<void> _processarEcadastrarMapa(
      String fileName, String fileExtension, String fileContent) async {
    print('DEBUG: Início de _processarEcadastrarMapa para arquivo: $fileName');
    List<Map<String, double>> coordinates = [];
    String mapaNome = fileName.split('.').first;
    String? status = 'aguardando';

    try {
      if (fileExtension.toLowerCase() == 'csv') {
        print('DEBUG: Processando arquivo CSV.');
        final csvList = const CsvToListConverter().convert(fileContent);
        for (var row in csvList) {
          if (row.length >= 2) {
            try {
              double lat = double.parse(row[0].toString());
              double lon = double.parse(row[1].toString());
              coordinates.add({'latitude': lat, 'longitude': lon});
            } catch (e) {
              print('ERRO: Erro ao parsear linha CSV: $row - $e');
            }
          }
        }
      } else if (fileExtension.toLowerCase() == 'kml') {
        print('DEBUG: Processando arquivo KML.');
        final document = XmlDocument.parse(fileContent);
        final coordinatesElements = document.findAllElements('coordinates');

        for (var element in coordinatesElements) {
          final coordsText = element.text.trim();
          final points = coordsText.split(' ');

          for (var point in points) {
            final parts = point.split(',');
            if (parts.length >= 2) {
              try {
                // KML geralmente usa Longitude, Latitude, Altitude
                double lon = double.parse(parts[0].toString());
                double lat = double.parse(parts[1].toString());
                coordinates.add({'latitude': lat, 'longitude': lon});
              } catch (e) {
                print('ERRO: Erro ao parsear ponto KML: $point - $e');
              }
            }
          }
        }
        final XmlElement? nameElement = document.findAllElements('name').firstWhereOrNull(
          (e) => e.parent is XmlElement && (e.parent as XmlElement).name.local == 'Document',
        ) ?? document.findAllElements('name').firstWhereOrNull(
          (e) => e.parent is XmlElement && (e.parent as XmlElement).name.local == 'Placemark',
        );


        if (nameElement != null) {
          mapaNome = nameElement.text.trim();
          print('DEBUG: Nome do mapa extraído do KML: $mapaNome');
        } else {
          print('DEBUG: Nome do mapa não encontrado no KML.');
        }
      } else {
        print('ERRO: Tipo de arquivo não suportado: $fileExtension');
        return;
      }

      if (coordinates.isEmpty) {
        print('DEBUG: Nenhuma coordenada encontrada no arquivo.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma coordenada válida encontrada no arquivo.')),
        );
        return;
      }

      // --- INÍCIO DA LÓGICA PARA CALCULAR O PONTO CENTRAL ---
      double totalLatitude = 0;
      double totalLongitude = 0;
      for (var coord in coordinates) {
        totalLatitude += coord['latitude']!;
        totalLongitude += coord['longitude']!;
      }

      final double centralLatitude = totalLatitude / coordinates.length;
      final double centralLongitude = totalLongitude / coordinates.length;

      final Map<String, double> pontoCentral = {
        'latitude': centralLatitude,
        'longitude': centralLongitude,
      };
      print('DEBUG: Ponto central calculado: $pontoCentral');
      // --- FIM DA LÓGICA ---

      print('DEBUG: Coordenadas processadas: ${coordinates.length} pontos.');
      print('DEBUG: Tentando cadastrar no Firestore...');

      await FirebaseFirestore.instance.collection('mapasGM').add({
        'mapa': mapaNome,
        'grupo': widget.nomeGrupo,
        'coordenadas': coordinates,
        'status': status,
        'dataInicio': null,
        'dataFim': null,
        'responsavel': null,
        'pontoCentral': pontoCentral, // Adicionando o ponto central aqui
      });

      print('DEBUG: Mapa cadastrado no Firestore com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mapa "$mapaNome" cadastrado com sucesso!')),
      );
    } catch (e) {
      print('ERRO CRÍTICO: Erro ao processar e cadastrar mapa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar mapa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nomeGrupo,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: widget.corTema,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selecionarArquivoMapa,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Procurar Mapa',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  buscaNome = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  _mostrarOpcoesOrdenacao(context);
                },
                icon: const Icon(Icons.sort),
                label: const Text('ORDENAR'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mapasGM')
                  .where('grupo', isEqualTo: widget.nomeGrupo)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar mapas: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum mapa encontrado para o grupo: ${widget.nomeGrupo}'));
                }

                List<DocumentSnapshot> documentosFirestore = snapshot.data!.docs;

                List<DocumentSnapshot> documentosFiltrados = documentosFirestore.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  String mapaNome = data['mapa'] as String? ?? '';
                  return mapaNome.toLowerCase().contains(buscaNome.toLowerCase());
                }).toList();

                documentosFiltrados.sort((a, b) {
                  Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
                  Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

                  bool aIniciadoNaoFinalizado = (dataA['status'] == 'iniciado' || dataA['status'] == 'ativo') && dataA['dataFim'] == null;
                  bool bIniciadoNaoFinalizado = (dataB['status'] == 'iniciado' || dataB['status'] == 'ativo') && dataB['dataFim'] == null;

                  if (aIniciadoNaoFinalizado && !bIniciadoNaoFinalizado) {
                    return -1;
                  } else if (!aIniciadoNaoFinalizado && bIniciadoNaoFinalizado) {
                    return 1;
                  } else {
                    switch (filtroOrdenacao) {
                      case 'nome':
                        return (dataA['mapa'] as String? ?? '').compareTo(dataB['mapa'] as String? ?? '');
                      case 'dataInicio':
                        Timestamp? tsA = dataA['dataInicio'] as Timestamp?;
                        Timestamp? tsB = dataB['dataInicio'] as Timestamp?;
                        DateTime? dateA = tsA?.toDate();
                        DateTime? dateB = tsB?.toDate();
                        if (dateA == null && dateB == null) return 0;
                        if (dateA == null) return 1;
                        if (dateB == null) return -1;
                        return dateA.compareTo(dateB);
                      case 'dataFim':
                        Timestamp? tsA = dataA['dataFim'] as Timestamp?;
                        Timestamp? tsB = dataB['dataFim'] as Timestamp?;
                        DateTime? dateA = tsA?.toDate();
                        DateTime? dateB = tsB?.toDate();
                        if (dateA == null && dateB == null) return 0;
                        if (dateA == null) return 1;
                        if (dateB == null) return -1;
                        return dateA.compareTo(dateB);
                      case 'status':
                        return (dataA['status'] as String? ?? '').compareTo(dataB['status'] as String? ?? '');
                      default:
                        return 0;
                    }
                  }
                });

                return ListView.builder(
                  itemCount: documentosFiltrados.length,
                  itemBuilder: (context, index) {
                    final doc = documentosFiltrados[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final mapaDocumentId = doc.id;
                    final mapaNomeParaExibir = data['mapa'] as String? ?? 'Mapa Sem Nome';

                    final isExpanded = expandedItemIds.contains(mapaDocumentId);
                    final isStartedNotFinished = (data['status'] == 'iniciado' || data['status'] == 'ativo') && data['dataFim'] == null;

                    final dataInicioFormatted = (data['dataInicio'] as Timestamp?) != null
                        ? "${(data['dataInicio'] as Timestamp).toDate().day.toString().padLeft(2, '0')}/${(data['dataInicio'] as Timestamp).toDate().month.toString().padLeft(2, '0')}/${(data['dataInicio'] as Timestamp).toDate().year}"
                        : '-';
                    final dataFimFormatted = (data['dataFim'] as Timestamp?) != null
                        ? "${(data['dataFim'] as Timestamp).toDate().day.toString().padLeft(2, '0')}/${(data['dataFim'] as Timestamp).toDate().month.toString().padLeft(2, '0')}/${(data['dataFim'] as Timestamp).toDate().year}"
                        : '-';

                    return Card(
                      color: isStartedNotFinished ? Colors.yellow[100] : null,
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        key: Key(mapaDocumentId),
                        initiallyExpanded: isExpanded,
                        leading: const Icon(Icons.map),
                        title: Text(mapaNomeParaExibir,
                            style: GoogleFonts.rajdhani(fontSize: 18)),
                        trailing:
                            Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                        onExpansionChanged: (bool expanded) {
                          print('Clicou no mapa ${mapaDocumentId}, expandido: $expanded');
                          setState(() {
                            if (expanded) {
                              expandedItemIds.add(mapaDocumentId);
                            } else {
                              expandedItemIds.remove(mapaDocumentId);
                            }
                            print('expandedItemIds após setState: $expandedItemIds');
                          });
                        },
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data Inicial: $dataInicioFormatted',
                                  style: GoogleFonts.rajdhani(fontSize: 16),
                                ),
                                Text(
                                  'Data de Encerramento: $dataFimFormatted',
                                  style: GoogleFonts.rajdhani(fontSize: 16),
                                ),
                                Text(
                                  'Último Responsável: ${data['responsavel'] ?? '-'}',
                                  style: GoogleFonts.rajdhani(fontSize: 16),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapaDetalhesScreen(
                                          mapaNome: mapaNomeParaExibir,
                                          mapaId: mapaDocumentId,
                                          // Adicione o ponto central se a tela de detalhes precisar dele
                                          pontoCentral: data['pontoCentral'] as Map<String, dynamic>?,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('VER MAPA'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcoesOrdenacao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Ordenar por Nome'),
                onTap: () {
                  setState(() {
                    filtroOrdenacao = 'nome';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ordenar por Data de Início'),
                onTap: () {
                  setState(() {
                    filtroOrdenacao = 'dataInicio';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Ordenar por Data de Encerramento'),
                onTap: () {
                  setState(() {
                    filtroOrdenacao = 'dataFim';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Ordenar por Status (Iniciados/Não Finalizados primeiro)'),
                onTap: () {
                  setState(() {
                    filtroOrdenacao = 'status';
                  });
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}