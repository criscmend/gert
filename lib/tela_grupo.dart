import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lista_grupo.dart'; // Importe a tela ListaGrupoScreen

class TelaGrupo extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nomeGrupo),
        backgroundColor: corTema,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.rajdhani( // Adicione esta propriedade
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
              'Dirigente: $dirigente',
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            Text(
              'Ajudante: $ajudante',
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            const SizedBox(height: 16.0),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('Mapa aqui')),
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
                            nomeGrupo: nomeGrupo,
                            nomeDirigente: dirigente,
                            nomeAjudante: ajudante,
                            corTema: corTema,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corTema,
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