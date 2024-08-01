import 'dart:convert';
import 'package:melhoreslugares/estado.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetalhesState();
  }
}

class _DetalhesState extends State<Detalhes> {
  late dynamic _feedEstatico;

  bool _temProduto = false;
  late dynamic _produto;

  late PageController _controladorSlides;
  late int _slideSelecionado;

  @override
  void initState() {
    super.initState();

    _lerFeedEstatico();
    _iniciarSlides();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<void> _lerFeedEstatico() async {
    final String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    _carregarProduto();
  }

  void _carregarProduto() {
    setState(() {
      _produto = _feedEstatico['lugares']
          .firstWhere((produto) => produto["_id"] == estadoApp.idProduto);

      _temProduto = _produto != null;
    });
  }

  Widget exibirProduto() {
    final List<String> imagens = _produto["detalhes"]["blobs"]
        .where((blob) => blob["type"] == "image")
        .map<String>((blob) => "lib/recursos/imagens/${blob["file"]}")
        .toList();

    final String avatar = "lib/recursos/imagens/${_produto["lugar"]["avatar"]}";

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 31, 28, 28),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Image.asset(avatar, width: 48), // Usando o avatar do JSON
                    Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(_produto["lugar"]["nome"]))
                  ]),
                  GestureDetector(
                      onTap: () {
                        estadoApp.mostrarProdutos();
                      },
                      child: const Icon(Icons.arrow_back))
                ])),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 275,
              child: PageView.builder(
                  itemCount: imagens.length,
                  controller: _controladorSlides,
                  onPageChanged: (slide) {
                    setState(() {
                      _slideSelecionado = slide;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.asset(imagens[index], fit: BoxFit.cover);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: PageViewDotIndicator(
                currentItem: _slideSelecionado,
                count: imagens.length,
                unselectedColor: Colors.black26,
                selectedColor: Colors.amber,
              ),
            ),
            Card(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_produto["detalhes"]["nome"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_produto["detalhes"]["descricao"]),
                ),
                Row(children: [
                  Padding(
                      padding:
                          const EdgeInsets.only(left: 8, bottom: 5, top: 8),
                      child: Text(
                          "R\$ ${_produto['detalhes']['tipo'].toString()}")),
                  Padding(
                      padding:
                          const EdgeInsets.only(left: 8, bottom: 5, top: 8),
                      child: Row(children: [
                        const Icon(Icons.favorite_rounded,
                            color: Colors.red, size: 18),
                        Text(_produto["nota"].toString())
                      ])),
                ])
              ]),
            )
          ]),
        ));
  }

  Widget exibirMensagemProdutoInexistente() {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text("Melhores Marcas"))
                  ]),
                  GestureDetector(
                      onTap: () {
                        estadoApp.mostrarProdutos();
                      },
                      child: const Icon(Icons.arrow_back))
                ])),
        body: const SizedBox.expand(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error, size: 32, color: Colors.red),
          Text("produto inexistente :(",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red)),
          Text("selecione outro produto na tela anterior",
              style: TextStyle(fontSize: 14))
        ])));
  }

  @override
  Widget build(BuildContext context) {
    Widget detalhes = const SizedBox.shrink();

    if (_temProduto) {
      detalhes = exibirProduto();
    } else {
      detalhes = exibirMensagemProdutoInexistente();
    }

    return detalhes;
  }
}
