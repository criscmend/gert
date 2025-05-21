import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'tela_grupo.dart'; 
import 'package:google_fonts/google_fonts.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized(); // Certifique-se de que os bindings estão inicializados

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GerT',
      theme: ThemeData(
        primarySwatch: Colors.grey, // Cor primária geral 
        canvasColor: const Color(0xFFD7D7D7), // Cor de fundo geral das telas
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Olá!',
                  style: GoogleFonts.pacifico(fontSize: 80.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'ESCOLHA O SEU GRUPO',
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaGrupo( 
                          nomeGrupo: 'GRUPO 1',
                          dirigente: 'Fulano da Silva',
                          ajudante: 'Ciclano da Costa',
                          corTema: Color(0xFF0C4758), // Cor do Grupo 1
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4758),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 120),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'GRUPO 1',
                    style: GoogleFonts.rajdhani(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaGrupo( // Removi o const
                          nomeGrupo: 'GRUPO 2',
                          dirigente: 'Beltrano Oliveira',
                          ajudante: 'Novo Ajudante',
                          corTema: Color(0xFF842900), // Cor do Grupo 2
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF842900),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 120),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'GRUPO 2',
                    style: GoogleFonts.rajdhani(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaGrupo( // Removi o const
                          nomeGrupo: 'GRUPO 3',
                          dirigente: 'Dirigente 3',
                          ajudante: 'Ajudante 3',
                          corTema: Color(0xFF334D2E), // Cor do Grupo 3
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334D2E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 120),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'GRUPO 3',
                    style: GoogleFonts.rajdhani(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaGrupo( // Removi o const
                          nomeGrupo: 'GRUPO 4',
                          dirigente: 'Dirigente 4',
                          ajudante: 'Ajudante 4',
                          corTema: Color(0xFF332456), // Cor do Grupo 4
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF332456),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 120),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'GRUPO 4',
                    style: GoogleFonts.rajdhani(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                // Botão para adicionar grupo (se necessário) - Implemente se precisar
              ],
            ),
          ),
        ],
      ),
    );
  }
}