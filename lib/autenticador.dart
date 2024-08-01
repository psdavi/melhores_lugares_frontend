class Usuario {
  String? _nome = "";
  String? get nome => _nome;
  set nome(String? nome) {
    _nome = nome;
  }

  String _email = "";
  String get email => _email;
  set email(String email) {
    _email = email;
  }

  Usuario(String? nome, String email) {
    _nome = nome;
    _email = email;
  }
}

class Autenticador {
  static Usuario? _usuarioAtual;

  static Future<Usuario> login() async {
    final usuario = Usuario("Davi Pires Souza", "davipires.ti@gmail.com");
    _usuarioAtual = usuario;
    return usuario;
  }

  static Future<Usuario?> recuperarUsuario() async {
    return _usuarioAtual;
  }

  static Future<void> logout() async {
    _usuarioAtual = null;
  }

  static bool estaLogado() {
    return _usuarioAtual != null;
  }
}
