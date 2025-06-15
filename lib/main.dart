import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'tela_grupo.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
        canvasColor: const Color(0xFFD7D7D7),
      ),
      home: const TelaInicial(),
      debugShowCheckedModeBanner: false,
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
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Olá!',
                    style: GoogleFonts.pacifico(fontSize: 90.0, fontWeight: FontWeight.normal, color: Colors.black87),
                  ),
                  const Text(
                    'ESCOLHA O SEU GRUPO:',
                    style: TextStyle(fontSize: 16.0, color: Colors.black26),
                  ),
                  const SizedBox(height:10.0),
                  
                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 1',
                    descricao: 'São Mateus',
                    dirigente: 'Mário Barbosa',
                    ajudante: 'Samuel Pinheiro',
                    corTema: const Color(0xFF0C4758),
                  ),
                  const SizedBox(height: 5.0),
                  
                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 2',
                    descricao: 'Saudade',
                    dirigente: 'Antônio Neto',
                    ajudante: 'César Filho',
                    corTema: const Color(0xFF842900),
                  ),
                  const SizedBox(height: 5.0),

                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 3',
                    descricao: 'Vicente Silveira',
                    dirigente: 'Elsilon dos Santos',
                    ajudante: 'Otacílio Barbosa',
                    corTema: const Color(0xFF334D2E),
                  ),
                  const SizedBox(height: 5.0),

                  _buildGroupButton(
                    context,
                    nomeGrupo: 'GRUPO 4',
                    descricao: 'Lineu Jucá',
                    dirigente: 'Elairton Souza',
                    ajudante: 'Renato Soares',
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

  Widget _buildGroupButton(
    BuildContext context, {
    required String nomeGrupo,
    required String descricao,
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
        minimumSize: const Size(240, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nomeGrupo,
            style: GoogleFonts.ptSansCaption(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Text(
            descricao,
            style: GoogleFonts.lato(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}