import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

// Este é um script autônomo. Para executá-lo, você usará o comando:
// flutter run lib/limpar_dados.dart

Future<void> main() async {
  // Inicialização necessária para conectar com o Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  print('--- INICIANDO LIMPEZA DO BANCO DE DADOS ---');

  // --- ETAPA 1: Limpar os campos de data e responsável nos mapas ---
  try {
    print('Limpando a coleção "mapasGM"...');
    final mapasSnapshot = await firestore.collection('mapasGM').get();
    
    // Usamos um 'WriteBatch' para executar todas as atualizações de uma só vez.
    // É mais rápido e eficiente.
    final batchMapas = firestore.batch();

    for (final doc in mapasSnapshot.docs) {
      batchMapas.update(doc.reference, {
        'dataInicio': null,
        'dataFim': null,
        'dataUltimaModificacao': null,
        'responsavel': null,
        'status': 'aguardando', // Reseta o status para o padrão inicial.
      });
    }
    await batchMapas.commit();
    print('Coleção "mapasGM" limpa com sucesso! (${mapasSnapshot.docs.length} documentos atualizados)');
  } catch (e) {
    print('ERRO ao limpar "mapasGM": $e');
  }


  // --- ETAPA 2: Zerar a lista de mapas concluídos nos ciclos ---
  try {
    print('Limpando a coleção "ciclos_grupo"...');
    final ciclosSnapshot = await firestore.collection('ciclos_grupo').get();
    
    final batchCiclos = firestore.batch();

    for (final doc in ciclosSnapshot.docs) {
      batchCiclos.update(doc.reference, {
        // Define o campo como uma lista vazia.
        'mapasConcluidos': [],
      });
    }
    await batchCiclos.commit();
    print('Coleção "ciclos_grupo" limpa com sucesso! (${ciclosSnapshot.docs.length} documentos atualizados)');

  } catch (e) {
    print('ERRO ao limpar "ciclos_grupo": $e');
  }


  print('--- LIMPEZA FINALIZADA ---');
}