import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Para formatar datas

class MapaDetalhesScreen extends StatefulWidget {
 final String mapaNome;
 final int mapaId; // Ou outra forma de identificar o mapa no seu banco de dados

 const MapaDetalhesScreen({Key? key, required this.mapaNome, required this.mapaId})
     : super(key: key);

 @override
 MapaDetalhesScreenState createState() => MapaDetalhesScreenState();
}

class MapaDetalhesScreenState extends State<MapaDetalhesScreen> {
 // Dados do mapa (substitua isso pela busca do seu banco de dados)
 DateTime? dataInicio;
 DateTime? dataEncerramento;
 String? ultimoResponsavel;
 String observacao = '';

 @override
 void initState() {
 super.initState();
 // Aqui você buscaria os dados do mapa do seu banco de dados
 // usando o widget.mapaId
 // Exemplo (substitua pela sua lógica real):
 // _buscarDadosDoMapa(widget.mapaId);

 // Dados de exemplo (para demonstração):
 dataInicio = DateTime.now().subtract(const Duration(days: 7));
 dataEncerramento = DateTime.now();
 ultimoResponsavel = 'Fulano da Silva';
 observacao = 'Território foi feito até a penúltima casa da Rua Alfa indo em direção da Rua Beta. Não bater na casa 123 da Rua Alfa.'; // Exemplo da imagem
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(
 title: Text(
 widget.mapaNome,
 style: const TextStyle(fontWeight: FontWeight.bold),
 ),
 ),
 body: SingleChildScrollView( // Para evitar overflow se o conteúdo for muito longo
 padding: const EdgeInsets.all(16.0),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // 1. Mapa com marcação (Google Maps)
 SizedBox(
 height: 300, // Ajuste a altura conforme necessário
 child: GoogleMap(
 initialCameraPosition: const CameraPosition(
 target: LatLng(-23.5639, -46.6567), // Coordenadas de São Paulo (exemplo)
 zoom: 13.0,
 ),
 markers: {
 // Adicione marcadores para as quadras do mapa
 const Marker(
 markerId: MarkerId('quadra1'),
 position: LatLng(-23.5639, -46.6567), // Ajuste as coordenadas
 infoWindow: InfoWindow(title: 'Quadra 1'),
 ),
 // Adicione mais marcadores para outras quadras
 },
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
 'Data da Última Vez Iniciado: ${dataInicio != null ? DateFormat('dd/MM/yyyy').format(dataInicio!) : 'Não Iniciado'}',
 ),
 Text(
 'Data da Última Vez Encerrado: ${dataEncerramento != null ? DateFormat('dd/MM/yyyy').format(dataEncerramento!) : 'Não Encerrado'}',
 ),
 Text('Último Responsável: ${ultimoResponsavel ?? '-'}'),
 const SizedBox(height: 16),

 // 3. Observação (com botão de editar)
 const Text(
 'Observação:',
 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
 ),
 const SizedBox(height: 8),
 Text(
 observacao,
 maxLines: 5, // Limita a exibição inicial a 5 linhas
 overflow: TextOverflow.ellipsis, // Adiciona "..." se o texto for muito longo
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
 ElevatedButton(
 onPressed: () {
 // Lógica para Iniciar o Mapa
 },
 style: ElevatedButton.styleFrom(
 backgroundColor: const Color(0xFF4A8C27), // Verde
 foregroundColor: Colors.white,
 ),
 child: const Text('Iniciar Mapa'),
 ),
 ElevatedButton(
 onPressed: () {
 // Lógica para Encerrar o Mapa
 },
 style: ElevatedButton.styleFrom(
 backgroundColor: const Color(0xFFC22626), // Vermelho
 foregroundColor: Colors.white,
 ),
 child: const Text('Encerrar Mapa'),
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
 builder: (context) {
 String tempObservacao = observacao;
 return AlertDialog(
 title: const Text('Editar Observação'),
 content: TextField(
 controller: TextEditingController(text: tempObservacao),
 maxLength: 100, // Limite de caracteres
 maxLines: null, // Permite múltiplas linhas
 onChanged: (value) {
 tempObservacao = value;
 },
 ),
 actions: [
 TextButton(
 onPressed: () {
 Navigator.pop(context, null); // Cancelar
 },
 child: const Text('Cancelar'),
 ),
 TextButton(
 onPressed: () {
 Navigator.pop(context, tempObservacao); // Salvar
 },
 child: const Text('Salvar'),
 ),
 ],
 );
 },
 );

 if (novaObservacao != null) {
 setState(() {
 observacao = novaObservacao;
 });
 }
 }
}