import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/index.dart';
import 'package:projetovi/pages/login.dart';
import 'package:projetovi/pages/utils.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codTerapeutaController = TextEditingController();

  List<DropdownMenuItem<int>> tiposAcesso = [
    const DropdownMenuItem(value: 1, child: Text("Terapeuta")),
    const DropdownMenuItem(value: 2, child: Text("Paciente")),
  ];
  int tipoAcessoAtual = 1;

  Future registraUsuario() async {
    if (validaSenha()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).then((UserCredential oUser) async {
        await gravaDadosUsuario(
          _nameController.text.trim(),
          _emailController.text.trim(),
          int.parse(_codTerapeutaController.text.trim()),
        );

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if(FirebaseAuth.instance.currentUser != null) Get.offAll(const Index());

      }).catchError((erro, stackTrace) {
        erroPadrao(titulo: 'Erro', mensagem: "${erro.code}");
      });
    }
  }

  Future gravaDadosUsuario(String name, String email, int codTerapeuta) async {
    Usuario oUsuario = Usuario(codTerapeuta: codTerapeuta, email: email, nome: name, tipoAcesso: tipoAcessoAtual);
    await FirebaseFirestore.instance.collection('usuarios').add(oUsuario.toJson());
  }

  bool validaSenha() {
    return (_passwordController.text.trim() == _confirmPasswordController.text.trim() && _passwordController.text.trim().length >= 6);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codTerapeutaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.deepPurple,
        title: const Center(child: Text('RPD - Cadastro')),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Icon(
                  Icons.lightbulb_outlined,
                  size: 100,
                ),
                const SizedBox(height: 25),

                // Bem vindo
                const Text(
                  'RPD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                  ),
                ),
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: tipoAcessoAtual,
                      items: tiposAcesso,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          tipoAcessoAtual = value!;
                        });
                      },
                    ),
                  ),
                ),

                // nome
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Nome Completo',
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Email',
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // senha
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Senha',
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // confirmar senha
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Confirmar Senha',
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // codigo terapeuta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 7,
                          controller: _codTerapeutaController,
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Código do Terapeuta',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.qr_code_scanner),
                        onPressed: () async {
                          await FlutterBarcodeScanner.scanBarcode(
                              '#673AB7', 'Cancelar', true, ScanMode.QR).then((String retornoQR){
                                if(retornoQR != '-1'){
                                  setState(() {
                                    _codTerapeutaController.text = retornoQR;
                                  });
                                }
                          }).catchError((erro,stackTrace) async {
                            await erroPadrao(titulo: 'Erro', mensagem: 'Houve um problema na leitura do código.');
                          });
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // botao entrar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: registraUsuario,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Realizar Cadastro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // registrar
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já possui uma conta?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Get.offAll(const Login());
                        },
                        child: const Text(
                          ' Entrar',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
