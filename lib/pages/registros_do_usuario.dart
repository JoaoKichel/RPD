import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projetovi/models/registros_pensamento.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/utils.dart';

import 'registro.dart';

class RegistrosDoUsuario extends StatefulWidget {
  Usuario oUsuarioPaciente;
  Usuario oUsuarioTerapeuta;
  RegistrosDoUsuario({Key? key, required this.oUsuarioPaciente, required this.oUsuarioTerapeuta}) : super(key: key);

  @override
  State<RegistrosDoUsuario> createState() => _RegistrosDoUsuarioState();
}

class _RegistrosDoUsuarioState extends State<RegistrosDoUsuario> {
  bool bCarregando = false;
  List<RegistroPensamento> listaPensamentos = [];

  @override
  void initState() {
    super.initState();
    buscaRegistros();
  }

  buscaRegistros() async {
    setState(() {
      bCarregando = true;
    });
    await FirebaseFirestore.instance
        .collection('pensamentos')
        .where('emailUsuario', isEqualTo: '${widget.oUsuarioPaciente.email}')
        .orderBy('dataHora',descending: true)
        .get()
        .then((retornoPensamentos) {
      listaPensamentos =
          retornoPensamentos.docs.map((docSnapshot) => RegistroPensamento.fromJson(docSnapshot.data())).toList();
    }).catchError((erro) {
      erroPadrao(titulo: "Erro", mensagem: "Erro ao buscar os dados do Usuário.");
    });
    setState(() {
      bCarregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.deepPurple,
          title: const Text('RPD - Registros de Pensamentos'),
        ),
        body: bCarregando
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.only(top:16.0,bottom:8.0,left:8.0,right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Registro de Pensamentos, paciente:", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 10,),
                  Text("${widget.oUsuarioPaciente.nome}", style: const TextStyle(fontSize:18.0,fontWeight: FontWeight.bold)),
                  SizedBox(height: 10,),
                  Divider(),
                  ListView.separated(
                    separatorBuilder: (BuildContext context, index) => const Divider(),
                      itemCount: listaPensamentos.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: retornaIconeHumor(listaPensamentos[index].indiceHumor!,tamanhoIcone: 40),
                          title: Text(formataData.format(listaPensamentos[index].dataHora!.toDate())),
                          onTap: ()async {
                            await Get.to(() => Registro(oRegistro: listaPensamentos[index],oUsuarioPaciente: widget.oUsuarioPaciente,oUsuarioTerapeuta: widget.oUsuarioTerapeuta,));
                          },
                        );
                      }),
                ],
              ),
            ));
  }
}
