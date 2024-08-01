import 'package:melhoreslugares/estado.dart';
import 'package:flutter/material.dart';

class ProdutoCard extends StatelessWidget {
  final dynamic produto;

  const ProdutoCard({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> blobs = produto["detalhes"]["blobs"];
    final String primeiraImagem = blobs.isNotEmpty
        ? "lib/recursos/imagens/${blobs[0]["file"]}"
        : "lib/recursos/imagens/default.jpg";

    final String avatar = "lib/recursos/imagens/${produto["lugar"]["avatar"]}";

    return GestureDetector(
      onTap: () {
        estadoApp.mostrarDetalhes(produto["_id"]);
      },
      child: Card(
        child: Column(children: [
          // Exibindo a primeira imagem dos blobs com tamanho fixo
          SizedBox(
            width: 200, // Largura fixa
            height: 150, // Altura fixa
            child: Image.asset(
              primeiraImagem,
              fit: BoxFit.cover, // Ajusta a imagem dentro do SizedBox
            ),
          ),
          Row(children: [
            // Exibindo o avatar do lugar
            CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(avatar)),
            Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(produto["detalhes"]["tipo"],
                    style: const TextStyle(fontSize: 15))),
          ]),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(produto["detalhes"]["nome"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 10),
              child: Text(produto["detalhes"]["url"])),
          const Spacer(),
          Row(children: [
            // Padding(
            //     padding: const EdgeInsets.only(left: 10, bottom: 5),
            //     child: Text("Nota ${produto['nota'].toString()}")
            //     ),
            Padding(
  padding: const EdgeInsets.only(left: 8, bottom: 5),
  child: Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 18), // Estrela em vez de coração
      Text(produto["nota"].toString())
    ],
  ),
),
          ])
        ]),
      ),
    );
  }
}
