import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melhoreslugares/telas/detalhes.dart';

class Top10MaisBemAvaliados extends StatelessWidget {
  final dynamic feedEstatico;
  const Top10MaisBemAvaliados({super.key, required this.feedEstatico});

  @override
  Widget build(BuildContext context) {
    List<dynamic> produtos = List.from(feedEstatico["lugares"]);
    
    // Ordena e pega os top 10 mais bem avaliados
    produtos.sort((a, b) => b["nota"].compareTo(a["nota"]));
    final top10 = produtos.take(10).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 28, 28),
        title: const Text('Top 10 Mais Bem Avaliados'),
      ),
      body: ListView.builder(
        itemCount: top10.length,
        itemBuilder: (context, index) {
          final produto = top10[index];
          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${index + 1}.",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8), // Espaço entre o número e o avatar
                CircleAvatar(
                  backgroundImage: AssetImage("lib/recursos/imagens/${produto["lugar"]["avatar"]}"),
                ),
              ],
            ),
            title: Text(produto["lugar"]["nome"]),
            subtitle: Text("Nota: ${produto["nota"].toString()}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detalhes(idProduto: produto["_id"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
