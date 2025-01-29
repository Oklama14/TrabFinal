import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  /// gravar produto
  Future<DocumentReference> gravar(String nome, String categoria,
      int quantidade, double preco, String? id) async {
    // dados do produto com valor padrão para preço
    Map<String, dynamic> dadosProduto = {
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'preco': preco,
      'data_cadastro': FieldValue.serverTimestamp(),
    };

    if (id != null && id != 'null') {
      // att de produto existente
      final documentRef = _firestore.collection('produtos').doc(id);

      // busca documento atual
      DocumentSnapshot docSnapshot = await documentRef.get();

      // se n existe o campo preco, adiciona valor padrão que é 0
      if (!docSnapshot.exists ||
          !(docSnapshot.data() as Map<String, dynamic>).containsKey('preco')) {
        dadosProduto['preco'] = 0.0;
      }

      await documentRef.update(dadosProduto);
      return documentRef;
    } else {
      return _firestore.collection('produtos').add(dadosProduto);
    }
  }

  /// lista todos os produtos
  CollectionReference listar() {
    return _firestore.collection('produtos');
  }

  /// exclur produto
  Future<void> excluir(String id) {
    final documentRef = _firestore.collection('produtos').doc(id);
    return documentRef.delete();
  }

  /// buscar produto
  Future<DocumentSnapshot<Map<String, dynamic>>>? buscarPorID(String id) {
    return _firestore.collection('produtos').doc(id).get();
  }

  /// att quantidade do produto
  Future<void> atualizarQuantidade(String id, int novaQuantidade) async {
    final documentRef = _firestore.collection('produtos').doc(id);
    await documentRef.update({
      'quantidade': novaQuantidade,
      'ultima_atualizacao': FieldValue.serverTimestamp()
    });
  }
}
