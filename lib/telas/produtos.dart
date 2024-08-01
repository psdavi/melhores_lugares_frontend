import 'dart:convert';
import 'package:melhoreslugares/componentes/produtocard.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melhoreslugares/autenticador.dart';
import 'package:melhoreslugares/estado.dart';
import 'package:melhoreslugares/telas/detalhes.dart';
import 'package:melhoreslugares/telas/top10_mais_bem_avaliados.dart'; // Nova importação

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
    _recuperarUsuarioLogado();
  }

  Future<void> _lerFeedEstatico() async {
    final String conteudoJson = await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    Set<String> tipos = {'Todos'};
    _feedEstatico["lugares"].forEach((produto) {
      tipos.add(produto["detalhes"]["tipo"]);
    });

    setState(() {
      _tipos = tipos.toList();
    });

    _carregarProdutos();
  }

  void _recuperarUsuarioLogado() {
    Autenticador.recuperarUsuario().then((usuario) {
      if (usuario != null) {
        setState(() {
          estadoApp.onLogin(usuario);
        });
      }
    });
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

  void _navegarParaDetalhes(int idProduto) {
    if (estadoApp.temUsuarioLogado()) {
      estadoApp.mostrarDetalhes(idProduto);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Detalhes(idProduto: idProduto),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Por favor, faça login para ver os detalhes do local.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 28, 28),
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
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
            DropdownButton<String>(
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
          ],
        ),
        actions: [
          // Novo botão
          IconButton(
            icon: const Icon(Icons.star, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Top10MaisBemAvaliados(feedEstatico: _feedEstatico),
                ),
              );
            },
          ),
          IconButton(
            icon: estadoApp.temUsuarioLogado() ? const Icon(Icons.logout, size: 30) : const Icon(Icons.person, size: 30),
            onPressed: () {
              if (estadoApp.temUsuarioLogado()) {
                Autenticador.logout().then((_) {
                  Fluttertoast.showToast(msg: "você não está mais conectado");
                  setState(() {
                    estadoApp.onLogout();
                  });
                });
              } else {
                Autenticador.login().then((usuario) {
                  Fluttertoast.showToast(msg: "você foi conectado com sucesso");
                  setState(() {
                    estadoApp.onLogin(usuario);
                  });
                });
              }
            },
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
          return GestureDetector(
            onTap: () => _navegarParaDetalhes(item["_id"]),
            child: SizedBox(height: 400, child: ProdutoCard(produto: item)),
          );
        },
      ),
    );
  }
}
