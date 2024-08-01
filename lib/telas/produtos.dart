import 'dart:convert';

import 'package:melhoreslugares/componentes/produtocard.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProdutosState();
  }
}

const int tamanhoPagina = 4;

class _ProdutosState extends State<Produtos> {
  late dynamic _feedEstatico;
  List<dynamic> _produtos = [];
  List<String> _tipos = ['Todos']; // Lista de tipos
  String _tipoSelecionado = 'Todos'; // Tipo selecionado

  int _proximaPagina = 1;
  bool _carregando = false;

  late TextEditingController _controladorFiltragem;
  String _filtro = "";

  @override
  void initState() {
    super.initState();

    _controladorFiltragem = TextEditingController();
    _lerFeedEstatico();
  }

  Future<void> _lerFeedEstatico() async {
    final String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    // Extraia os tipos únicos dos produtos e adicione à lista de tipos
    Set<String> tipos = {'Todos'};
    _feedEstatico["lugares"].forEach((produto) {
      tipos.add(produto["detalhes"]["tipo"]);
    });

    setState(() {
      _tipos = tipos.toList();
    });

    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _carregando = true;
    });

    List<dynamic> maisProdutos = [];

    if (_filtro.isNotEmpty) {
      maisProdutos = _feedEstatico["lugares"].where((item) {
        String nome = item["detalhes"]["nome"];
        return nome.toLowerCase().contains(_filtro.toLowerCase()) &&
               (_tipoSelecionado == 'Todos' || item["detalhes"]["tipo"] == _tipoSelecionado);
      }).toList();
    } else {
      if (_tipoSelecionado == 'Todos') {
        maisProdutos = _feedEstatico["lugares"];
      } else {
        maisProdutos = _feedEstatico["lugares"].where((item) => item["detalhes"]["tipo"] == _tipoSelecionado).toList();
      }

      final totalProdutosParaCarregar = _proximaPagina * tamanhoPagina;
      if (maisProdutos.length >= totalProdutosParaCarregar) {
        maisProdutos = maisProdutos.sublist(0, totalProdutosParaCarregar);
      }
    }

    // Ordena os produtos pela nota em ordem decrescente
    maisProdutos.sort((a, b) => b["nota"].compareTo(a["nota"]));

    setState(() {
      _produtos = maisProdutos;
      _proximaPagina = _proximaPagina + 1;

      _carregando = false;
    });
  }

  Future<void> _atualizarProdutos() async {
    _produtos = [];
    _proximaPagina = 1;

    _carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 31, 28, 28),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 60, right: 20),
              child: TextField(
                controller: _controladorFiltragem,
                onSubmitted: (descricao) {
                  setState(() {
                    _filtro = descricao;
                  });
                  _atualizarProdutos();
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: _tipoSelecionado,
              onChanged: (String? novoTipo) {
                if (novoTipo != null) {
                  setState(() {
                    _tipoSelecionado = novoTipo;
                  });
                  _atualizarProdutos();
                }
              },
              items: _tipos.map<DropdownMenuItem<String>>((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: FlatList(
        data: _produtos,
        numColumns: 2,
        loading: _carregando,
        onRefresh: () {
          _filtro = "";
          _controladorFiltragem.clear();
          return _atualizarProdutos();
        },
        onEndReached: () => _carregarProdutos(),
        buildItem: (item, int indice) {
          return SizedBox(height: 400, child: ProdutoCard(produto: item));
        },
      ),
    );
  }
}
