import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  List<Map<String, dynamic>> mapas = [
    // Dados dos mapas (simulação)
    {
      "id": 1,
      "nome": "Mapa 1 - Referência",
      "dataInicio": "2024-01-01",
      "dataFim": "2024-01-10",
      "responsavel": "Fulano",
      "status": "encerrado"
    },
    {
      "id": 2,
      "nome": "Mapa 2 - Referência",
      "dataInicio": "2024-02-15",
      "dataFim": null,
      "responsavel": "Ciclano",
      "status": "iniciado"
    },
    {
      "id": 3,
      "nome": "Mapa 3 - Referência",
      "dataInicio": "2024-03-01",
      "dataFim": null,
      "responsavel": "Beltrano",
      "status": "iniciado"
    },
    {
      "id": 4,
      "nome": "Mapa 4 - Referência",
      "dataInicio": "2024-04-01",
      "dataFim": "2024-04-15",
      "responsavel": "Deltrano",
      "status": "encerrado"
    },
    {
      "id": 5,
      "nome": "Mapa 5 - Referência",
      "dataInicio": "2024-05-01",
      "dataFim": null,
      "responsavel": "Fulano",
      "status": "ativo"
    },
    // ... mais mapas
  ];

  String filtroOrdenacao = 'nome'; // Padrão
  String buscaNome = '';
  List<int> expandedItems = []; // Controla quais mapas estão expandidos

  @override
  Widget build(BuildContext context) {
    // Ordena os mapas com status "iniciado" e sem dataFim no início
    List<Map<String, dynamic>> mapasOrdenados = List.from(mapas);
    mapasOrdenados.sort((a, b) {
      if (a['status'] == 'iniciado' && a['dataFim'] == null) {
        return -1; // a vem antes
      } else if (b['status'] == 'iniciado' && b['dataFim'] == null) {
        return 1; // b vem antes
      } else {
        return 0; // mesma ordem
      }
    });

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
            color: Colors.white, // Defina a cor da letra do título aqui
          ),
        ),
      ],
    ),
    backgroundColor: widget.corTema,
    iconTheme: const IconThemeData(
      color: Colors.white, // Defina a cor dos ícones aqui
    ),
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
                  // Mostrar opções de ordenação
                  _mostrarOpcoesOrdenacao(context);
                },
                icon: const Icon(Icons.sort),
                label: const Text('ORDENAR'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mapasOrdenados.length, // Usa a lista ordenada
              itemBuilder: (context, index) {
                final mapa = mapasOrdenados[index]; // Usa a lista ordenada
                final isExpanded = expandedItems.contains(mapa['id']);
                final isStartedNotFinished =
                    mapa['status'] == 'iniciado' && mapa['dataFim'] == null;

                // Aplicar filtro de busca
                if (!mapa['nome'].toLowerCase().contains(buscaNome.toLowerCase())) {
                  return const SizedBox.shrink(); // Oculta o mapa se não corresponder à busca
                }

                return Card(
                  color: isStartedNotFinished
                      ? Colors.yellow[100]
                      : null, // Destaque para mapas iniciados
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    key: Key(mapa['id'].toString()),
                    leading: const Icon(Icons.map),
                    title: Text(mapa['nome'],
                        style: GoogleFonts.rajdhani(fontSize: 18)),
                    trailing:
                        Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        if (expanded) {
                          expandedItems.add(mapa['id']);
                        } else {
                          expandedItems.remove(mapa['id']);
                        }
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Inicial: ${mapa['dataInicio'] ?? '-'}',
                              style: GoogleFonts.rajdhani(fontSize: 16),
                            ),
                            Text(
                              'Data de Encerramento: ${mapa['dataFim'] ?? '-'}',
                              style: GoogleFonts.rajdhani(fontSize: 16),
                            ),
                            Text(
                              'Último Responsável: ${mapa['responsavel'] ?? '-'}',
                              style: GoogleFonts.rajdhani(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Navegar para a tela do mapa (passar o ID do mapa)
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
                  mapas.sort((a, b) => a['nome'].compareTo(b['nome']));
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
                  mapas.sort((a, b) => (a['dataInicio'] ?? '').compareTo(b['dataInicio'] ?? ''));
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
                  mapas.sort((a, b) => (a['dataFim'] ?? '').compareTo(b['dataFim'] ?? ''));
                });
                Navigator.pop(context);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Adiciona um espaço extra no final
          ],
        ),
      );
    },
  );
 }
}