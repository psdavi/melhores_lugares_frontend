import 'package:flutter/material.dart';

enum Situacao { mostrandoProdutos, mostrandoDetalhes }

class EstadoApp extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoProdutos;
  Situacao get situacao => _situacao;

  late int _idProduto;
  int get idProduto => _idProduto;

  void mostrarProdutos() {
    _situacao = Situacao.mostrandoProdutos;

    notifyListeners();
  }

  void mostrarDetalhes(int idProduto) {
    _situacao = Situacao.mostrandoDetalhes;
    _idProduto = idProduto;

    notifyListeners();
  }
}

late EstadoApp estadoApp;
