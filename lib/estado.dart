// ignore_for_file: unnecessary_getters_setters
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'autenticador.dart';

enum Situacao { mostrandoProdutos, mostrandoDetalhes }

class EstadoApp extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoProdutos;
  Situacao get situacao => _situacao;
  set situacao(Situacao situacao) {
    _situacao = situacao;
    notifyListeners();
  }

  int _idProduto = 0;
  int get idProduto => _idProduto;
  set idProduto(int idProduto) {
    _idProduto = idProduto;
    notifyListeners();
  }

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  set usuario(Usuario? usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void mostrarProdutos() {
    situacao = Situacao.mostrandoProdutos;
  }

  void mostrarDetalhes(int idProduto) {
    if (_usuario != null) {
      situacao = Situacao.mostrandoDetalhes;
      this.idProduto = idProduto;
    } else {
      Fluttertoast.showToast(msg: "Por favor, faça login para ver os detalhes do local.");
    }
  }

  void onLogin(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void onLogout() {
    _usuario = null;
    notifyListeners();
  }

  bool temUsuarioLogado() {
    return _usuario != null;
  }
}

late EstadoApp estadoApp = EstadoApp();