
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:projetovi/models/sintoma.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/login.dart';
import 'package:projetovi/pages/registros_do_usuario.dart';
import 'package:projetovi/pages/selecao_pacientes.dart';

var formataData = DateFormat("dd/MM/yyyy hh:mm");

List<Sintoma> listaSintomas = [
  Sintoma(codigo: 0, descricao: 'Falta de Ar'),
  Sintoma(codigo: 1, descricao: 'Tontura'),
  Sintoma(codigo: 2, descricao: 'Tremores'),
  Sintoma(codigo: 3, descricao: 'Agitação'),
  Sintoma(codigo: 4, descricao: 'Sudorese'),
  Sintoma(codigo: 5, descricao: 'Palpitação'),
  Sintoma(codigo: 6, descricao: 'Cansaço'),
  Sintoma(codigo: 7, descricao: 'Dor de Barriga'),
  Sintoma(codigo: 8, descricao: 'Tensão Muscular'),
  Sintoma(codigo: 9, descricao: 'Crise de choro'),
];

retornaDrawer({required User user, required Usuario? oUsuario}) {
  Widget fotoUsuario = CircleAvatar(
      radius: 100,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.network(
              "${user.photoURL ?? "https://blueheronhillsgc.com/wp-content/uploads/2020/08/no-photo-male.jpg"}")));
  return Drawer(
      elevation: 10.0,
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            accountName: Text("${oUsuario?.nome}"),
            accountEmail: Text("${oUsuario?.email}"),
            currentAccountPicture: fotoUsuario,
          ),
          // ListTile(
          //   leading: const Icon(Icons.add),
          //   title: const Text("Registro de Pensamento"),
          //   onTap: () async {
          //     await Get.to(const Index());
          //   },
          // ),
          if(oUsuario?.tipoAcesso == 2) ListTile(
            leading: const Icon(Icons.read_more),
            title: const Text("Meus Registros"),
            onTap: () async {
              await Get.to(() => RegistrosDoUsuario(oUsuarioPaciente: oUsuario!,oUsuarioTerapeuta: oUsuario,));
              },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Sair"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              await Get.offAll(const Login());
            },
          ),
        ],
      ));
}

erroPadrao({required String titulo, required String mensagem}){
  return Get.snackbar(titulo, mensagem,
      backgroundColor: Colors.red, colorText: Colors.white,icon: const Icon(Icons.error,color: Colors.white,));
}

sucessoPadrao({required String titulo, required String mensagem}){
  return Get.snackbar(titulo, mensagem,
      backgroundColor: Colors.green, colorText: Colors.white,icon: const Icon(Icons.check_circle,color: Colors.white,));
}

Future<Usuario?> carregaDadosUsuario(User? user) async {
  return await FirebaseFirestore.instance
      .collection('usuarios')
      .where('email', isEqualTo: '${user?.email}')
      .limit(1)
      .get(const GetOptions(source: Source.server))
      .then((retornoUsuario) {
       return retornoUsuario.docs.map((docSnapshot) => Usuario.fromJson(docSnapshot.data())).toList().first;
  }).catchError((erro){
    erroPadrao(titulo: "Erro",mensagem: "Erro ao buscar os dados do Usuário.");
  });
}

Icon retornaIconeHumor(int indice, {double tamanhoIcone = 50}) {
  switch (indice) {
    case 1:
      {
        return Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.red,
          size: tamanhoIcone,
        );
      }
    case 2:
      {
        return Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.redAccent,
          size: tamanhoIcone,
        );
      }
    case 3:
      {
        return Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
          size: tamanhoIcone,
        );
      }
    case 4:
      {
        return Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
          size: tamanhoIcone,

        );
      }
    case 5:
      {
        return Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
          size: tamanhoIcone,
        );
      }
    default: {
      return Icon(
        Icons.sentiment_very_satisfied,
        color: Colors.green,
        size: tamanhoIcone,
      );
    }
  }
}