import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> criarNovaConta(
      {required String nome,
      required String email,
      required String senha,
      String? cargo = 'Padrão'}) async {
    try {
      // Validações básicas
      if (nome.length < 3) {
        throw Exception('Nome deve ter no mínimo 3 caracteres');
      }

      if (senha.length < 6) {
        throw Exception('Senha deve ter no mínimo 6 caracteres');
      }

      // Criar usuário no Firebase Authentication
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);

      User? usuario = credencial.user;

      if (usuario != null) {
        // Atualizar nome de exibição
        await usuario.updateDisplayName(nome);

        // Salvar informações adicionais no Firestore
        await _firestore.collection('usuarios').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'cargo': cargo,
          'data_criacao': FieldValue.serverTimestamp(),
          'ultimo_login': null,
        });

        return usuario;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _tratarErroAutenticacao(e);
    }
  }

  Future<User?> login(String email, String senha) async {
    try {
      UserCredential credencial =
          await _auth.signInWithEmailAndPassword(email: email, password: senha);

      User? usuario = credencial.user;

      if (usuario != null) {
        // Atualizar último login
        await _firestore
            .collection('usuarios')
            .doc(usuario.uid)
            .update({'ultimo_login': FieldValue.serverTimestamp()});

        return usuario;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _tratarErroAutenticacao(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _tratarErroAutenticacao(e);
    }
  }

  String _tratarErroAutenticacao(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Senha muito fraca';
      case 'email-already-in-use':
        return 'Email já cadastrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }

  User? getUsuarioAtual() {
    return _auth.currentUser;
  }
}
