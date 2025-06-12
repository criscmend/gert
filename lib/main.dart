import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'tela_grupo.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  // Garante que o Flutter e o Firebase sejam inicializados antes de rodar o app.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Trava a orientação do app para retrato.
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
        primarySwatch: Colors.grey, 
        canvasColor: const Color(0xFFD7D7D7), // Cor de fundo padrão das telas.
      ),
      home: const TelaInicial(),
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug"
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
          // Imagem de fundo (certifique-se que 'assets/background.png' existe no seu pubspec.yaml)
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            // ALTERAÇÃO: Adicionado SingleChildScrollView para garantir que a tela seja rolável
            // caso mais botões sejam adicionados no futuro, evitando erros de layout.
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Olá!',
                    style: GoogleFonts.pacifico(fontSize: 70.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'ESCOLHA O SEU GRUPO',
                    style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  ),
                  const SizedBox(height: 32.0),
                  
                  // Botão do GRUPO 1
                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 1',
                    dirigente: 'Fulano da Silva',
                    ajudante: 'Ciclano da Costa',
                    corTema: const Color(0xFF0C4758),
                  ),
                  const SizedBox(height: 16.0),
                  
                  // ALTERAÇÃO: Adicionados os botões para os outros grupos.
                  // Botão do GRUPO 2
                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 2',
                    dirigente: 'Beltrano Oliveira',
                    ajudante: 'Novo Ajudante',
                    corTema: const Color(0xFF842900),
                  ),
                  const SizedBox(height: 16.0),

                  // Botão do GRUPO 3
                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 3',
                    dirigente: 'Dirigente 3',
                    ajudante: 'Ajudante 3',
                    corTema: const Color(0xFF334D2E),
                  ),
                  const SizedBox(height: 16.0),

                  // Botão do GRUPO 4
                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 4',
                    dirigente: 'Dirigente 4',
                    ajudante: 'Ajudante 4',
                    corTema: const Color(0xFF332456),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET NOVO: Criei este método para evitar a repetição de código dos botões.
  // Ele cria um botão de grupo padronizado.
  Widget _buildGroupButton(
    BuildContext context, {
    required String nomeGrupo,
    required String dirigente,
    required String ajudante,
    required Color corTema,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaGrupo(
              nomeGrupo: nomeGrupo,
              dirigente: dirigente,
              ajudante: ajudante,
              corTema: corTema,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: corTema,
        foregroundColor: Colors.white,
        minimumSize: const Size(240, 120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        nomeGrupo,
        style: GoogleFonts.rajdhani(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}