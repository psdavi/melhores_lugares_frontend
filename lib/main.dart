import 'package:melhoreslugares/estado.dart';
import 'package:melhoreslugares/telas/detalhes.dart';
import 'package:melhoreslugares/telas/produtos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => EstadoApp(),
        child: MaterialApp(
          title: "Melhores Lugares",
          theme: ThemeData(
              colorScheme: const ColorScheme.dark(), useMaterial3: true),
          home: const Tela(),
        ));
  }
}

class Tela extends StatefulWidget {
  const Tela({super.key});

  @override
  State<Tela> createState() => _TelaState();
}

class _TelaState extends State<Tela> {
  void _exibirComoRetrato() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _exibirComoRetrato();

    estadoApp = context.watch<EstadoApp>();

    Widget tela = const SizedBox.shrink();
    if (estadoApp.situacao == Situacao.mostrandoProdutos) {
      tela = const Produtos();
    } else if (estadoApp.situacao == Situacao.mostrandoDetalhes) {
      tela = const Detalhes();
    }

    return tela;
  }
}
