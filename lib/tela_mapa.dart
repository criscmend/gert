import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore

class MapaDetalhesScreen extends StatefulWidget {
  final String mapaNome;
  final String mapaId; // Usaremos String para o ID do documento do Firestore
  final Map<String, dynamic>? pontoCentral; // Adicionado pontoCentral (do Navigator)

  const MapaDetalhesScreen({
    Key? key,
    required this.mapaNome,
    required this.mapaId,
    this.pontoCentral, // Adicionado pontoCentral
  }) : super(key: key);

  @override
  MapaDetalhesScreenState createState() => MapaDetalhesScreenState();
}

class MapaDetalhesScreenState extends State<MapaDetalhesScreen> {
  // Variáveis para armazenar os dados do Firestore
  DateTime? dataInicio;
  DateTime? dataEncerramento; // Corresponde a 'dataFim' no Firestore
  String? ultimoResponsavel; // Corresponde a 'responsavel' no Firestore
  String observacao = '';
  List<LatLng> _polygonPoints = []; // Corresponde a 'coordenadas' no Firestore
  LatLng _cameraTarget = const LatLng(-23.5639, -46.6567); // Valor padrão inicial
  String _status = 'aguardando'; // Adicionada variável de status para controlar o estado do mapa

  // Flag para controlar o carregamento dos dados
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializa _cameraTarget usando o pontoCentral passado pelo widget,
    // que será sobrescrito se houver um pontoCentral no Firestore.
    if (widget.pontoCentral != null &&
        widget.pontoCentral!['latitude'] != null &&
        widget.pontoCentral!['longitude'] != null) {
      _cameraTarget = LatLng(
        (widget.pontoCentral!['latitude'] as num).toDouble(),
        (widget.pontoCentral!['longitude'] as num).toDouble(),
      );
    }
    _fetchMapData(); // Chama a função para buscar os dados do Firestore
  }

  // Função para buscar os dados do Firestore
  Future<void> _fetchMapData() async {
    setState(() {
      _isLoading = true; // Define como carregando antes de buscar
    });
    try {
      DocumentSnapshot mapDoc = await FirebaseFirestore.instance
          .collection('mapasGM') // Nome da sua coleção no Firestore
          .doc(widget.mapaId) // O ID do documento
          .get();

      if (mapDoc.exists && mapDoc.data() != null) {
        Map<String, dynamic> data = mapDoc.data() as Map<String, dynamic>;

        setState(() {
          dataInicio = (data['dataInicio'] as Timestamp?)?.toDate();
          dataEncerramento = (data['dataFim'] as Timestamp?)?.toDate();
          ultimoResponsavel = data['responsavel'] as String?;
          observacao = data['observacao'] as String? ?? '';
          _status = data['status'] as String? ?? 'aguardando'; // Atualiza o status

          // Parseando as coordenadas do polígono (campo 'coordenadas')
          List<dynamic>? rawCoords = data['coordenadas'] as List<dynamic>?;
          if (rawCoords != null) {
            _polygonPoints = rawCoords.map((pointMap) {
              double lat = (pointMap['latitude'] is num)
                      ? (pointMap['latitude'] as num).toDouble()
                      : double.tryParse(pointMap['latitude'].toString()) ?? 0.0;
              double lon = (pointMap['longitude'] is num)
                      ? (pointMap['longitude'] as num).toDouble()
                      : double.tryParse(pointMap['longitude'].toString()) ?? 0.0;
              return LatLng(lat, lon);
            }).toList();
          }

          // Se o ponto central existir no Firestore, use-o para o target da câmera
          Map<String, dynamic>? firestoreCenter = data['pontoCentral'] as Map<String, dynamic>?;
          if (firestoreCenter != null &&
              firestoreCenter['latitude'] != null &&
              firestoreCenter['longitude'] != null) {
            _cameraTarget = LatLng(
              (firestoreCenter['latitude'] as num).toDouble(),
              (firestoreCenter['longitude'] as num).toDouble(),
            );
          }
          _isLoading = false; // Dados carregados
        });
      } else {
        print('Documento do mapa ${widget.mapaId} não encontrado na coleção mapasGM.');
        setState(() {
          _isLoading = false; // Carregamento concluído, mesmo se não encontrou
        });
      }
    } catch (e) {
      print('Erro ao buscar dados do mapa: $e');
      // Adicione um feedback visual para o usuário em caso de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados do mapa: $e')),
      );
      setState(() {
        _isLoading = false; // Carregamento concluído com erro
      });
    }
  }

  // Função para criar o Polygon a partir dos pontos
  Set<Polygon> _createPolygon() {
    if (_polygonPoints.isEmpty) {
      return {};
    }
    return {
      Polygon(
        polygonId: const PolygonId('mapaPolygon'),
        points: _polygonPoints,
        strokeWidth: 2,
        strokeColor: Colors.blue.shade700,
        fillColor: Colors.blue.shade100.withOpacity(0.5),
      ),
    };
  }

  // Função para mostrar o popup de confirmação e responsável
  Future<Map<String, String>?> _showConfirmationDialog(String actionText) async {
    TextEditingController responsibleController = TextEditingController();
    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false, // Não permite fechar clicando fora
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirma $actionText esse mapa?'),
          content: TextField(
            controller: responsibleController,
            decoration: const InputDecoration(labelText: 'Nome do Responsável'),
            maxLength: 50,
            autofocus: true, // Foca no campo ao abrir o dialog
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null); // Retorna null se cancelar
              },
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                if (responsibleController.text.trim().isEmpty) {
                  // Mostra um aviso se o campo estiver vazio
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Por favor, informe o nome do responsável.')),
                  );
                } else {
                  Navigator.of(dialogContext).pop({
                    'action': actionText,
                    'responsavel': responsibleController.text.trim(),
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Função para atualizar o status do mapa no Firestore
  Future<void> _performMapAction(String newStatus, String dateField) async {
    final result = await _showConfirmationDialog(newStatus == 'iniciado' ? 'iniciar' : 'encerrar');

    if (result != null) {
      final responsibleName = result['responsavel'];
      if (responsibleName != null && responsibleName.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('mapasGM')
              .doc(widget.mapaId)
              .update({
            'status': newStatus,
            dateField: Timestamp.now(), // Grava a data e hora atual
            'responsavel': responsibleName, // Grava o nome do responsável
          });
          print('DEBUG: Mapa ${widget.mapaId} atualizado para status: $newStatus');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mapa ${widget.mapaNome} ${newStatus == 'iniciado' ? 'iniciado' : 'encerrado'} com sucesso!')),
          );
          // Re-fetch os dados para atualizar a UI e o estado dos botões
          await _fetchMapData();
        } catch (e) {
          print('ERRO: Falha ao atualizar status do mapa no Firestore: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao ${newStatus == 'iniciado' ? 'iniciar' : 'encerrar'} mapa.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para determinar a ativação dos botões
    bool canStartMap = (_status == 'aguardando' || _status == 'encerrado' || _status == 'finalizado');
    bool canEndMap = (_status == 'iniciado' || _status == 'ativo');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mapaNome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading // Mostra um indicador de carregamento enquanto busca os dados
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Mapa com polígono (Google Maps)
                  SizedBox(
                    height: 300, // Ajuste a altura conforme necessário
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _cameraTarget,
                        zoom: 15.0, // Ajuste o zoom conforme necessário
                      ),
                      polygons: _createPolygon(),
                      markers: {
                        Marker(
                          markerId: const MarkerId('center_marker'),
                          position: _cameraTarget,
                          infoWindow:
                              InfoWindow(title: 'Centro do ${widget.mapaNome}'),
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Detalhes do Mapa
                  const Text(
                    'Detalhes do Mapa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data da Última Vez Iniciado: ${dataInicio != null ? DateFormat('dd/MM/yyyy HH:mm').format(dataInicio!) : 'Não Iniciado'}',
                  ),
                  Text(
                    'Data da Última Vez Encerrado: ${dataEncerramento != null ? DateFormat('dd/MM/yyyy HH:mm').format(dataEncerramento!) : 'Não Encerrado'}',
                  ),
                  Text('Último Responsável: ${ultimoResponsavel ?? '-'}'),
                  Text('Status: ${_status == 'iniciado' ? 'Iniciado' : (_status == 'encerrado' ? 'Encerrado' : 'Aguardando')}'),
                  const SizedBox(height: 16),

                  // 3. Observação (com botão de editar)
                  const Text(
                    'Observação:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    observacao,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _editarObservacao(context);
                    },
                    child: const Text('Editar Observação'),
                  ),
                  const SizedBox(height: 24),

                  // 4. Botões Iniciar/Encerrar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded( // Usa Expanded para que os botões ocupem o espaço de forma igual
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            // Ativo se puder iniciar (aguardando ou encerrado)
                            onPressed: canStartMap ? () async {
                              await _performMapAction('iniciado', 'dataInicio');
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canStartMap
                                  ? const Color(0xFF4A8C27) // Verde
                                  : Colors.grey, // Acinzentado se desativado
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Iniciar Mapa', textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      Expanded( // Usa Expanded para que os botões ocupem o espaço de forma igual
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            // Ativo se puder encerrar (somente se estiver iniciado)
                            onPressed: canEndMap ? () async {
                              await _performMapAction('encerrado', 'dataFim');
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canEndMap
                                  ? const Color(0xFFC22626) // Vermelho
                                  : Colors.grey, // Acinzentado se desativado
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Encerrar Mapa', textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _editarObservacao(BuildContext context) async {
    final novaObservacao = await showDialog<String>(
      context: context,
      barrierDismissible: false, // Não permite fechar clicando fora
      builder: (context) {
        TextEditingController _obsController = TextEditingController(text: observacao);
        return AlertDialog(
          title: const Text('Editar Observação'),
          content: TextField(
            controller: _obsController,
            maxLength: 100,
            maxLines: null, // Permite múltiplas linhas
            keyboardType: TextInputType.multiline, // Teclado multiline
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _obsController.text.trim());
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novaObservacao != null && novaObservacao != observacao) { // Verifica se houve alteração
      setState(() {
        observacao = novaObservacao;
      });
      // Salvar a observação atualizada no Firestore
      try {
        await FirebaseFirestore.instance
            .collection('mapasGM')
            .doc(widget.mapaId)
            .update({'observacao': novaObservacao});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Observação atualizada com sucesso!')),
        );
      } catch (e) {
        print('ERRO: Falha ao atualizar observação no Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar observação.')),
        );
      }
    }
  }
}