import 'package:appfirebase/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/firestore_service.dart';

class ProdutoPage extends StatefulWidget {
  String? id;
  ProdutoPage({this.id, super.key});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  final TextEditingController _txtNome = TextEditingController();
  final TextEditingController _txtCategoria = TextEditingController();
  final TextEditingController _txtQuantidade = TextEditingController();
  final TextEditingController _txtPreco = TextEditingController();

  final FirestoreService servico = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.id != null) {
      servico.buscarPorID(widget.id!)!.then((dados) {
        setState(() {
          _txtNome.text = dados['nome'];
          _txtCategoria.text = dados['categoria'];
          _txtQuantidade.text = dados['quantidade'].toString();
          _txtPreco.text = dados['preco'].toString();
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id == null ? 'Novo Produto' : 'Editar Produto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[500],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  controller: _txtNome,
                  label: 'Nome do Produto',
                  icon: Icons.shopping_basket,
                  validator: (value) => value!.isEmpty ? 'digite o nome' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _txtCategoria,
                  label: 'Categoria',
                  icon: Icons.category,
                  validator: (value) =>
                      value!.isEmpty ? 'digite a categoria' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _txtQuantidade,
                  label: 'Quantidade',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'digite a quantidade' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _txtPreco,
                  label: 'Preço',
                  icon: Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value!.isEmpty ? 'digite o preço' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _salvarProduto,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference resposta = await servico.gravar(
          _txtNome.text,
          _txtCategoria.text,
          int.parse(_txtQuantidade.text),
          double.parse(_txtPreco.text),
          widget.id,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
