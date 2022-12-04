import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projetovi/models/registros_pensamento.dart';
import 'package:projetovi/models/sintoma.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/comentario.dart';
import 'package:projetovi/pages/utils.dart';

class Registro extends StatefulWidget {
  RegistroPensamento oRegistro;
  Usuario oUsuarioPaciente;
  Usuario oUsuarioTerapeuta;
  Registro({Key? key, required this.oRegistro, required this.oUsuarioPaciente, required this.oUsuarioTerapeuta})
      : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final user = FirebaseAuth.instance.currentUser!;
  bool bCarregando = false;

  final controladorSituacao = TextEditingController();
  List<Sintoma>? listaSintomasSelecionados;

  @override
  void initState() {
    super.initState();
    controladorSituacao.text = widget.oRegistro.descricaoSituacao ?? '';
    listaSintomasSelecionados = listaSintomas
        .where((element) =>
            widget.oRegistro.listaSintomas!.contains(element.codigo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.deepPurple,
          title: const Text('RPD - Registro'),
        ),
        body: bCarregando
            ? const Center(child: CircularProgressIndicator())
            : Scrollbar(
              isAlwaysShown: true,
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Paciente ${widget.oUsuarioPaciente.nome}",
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Data/Hora: ${formataData.format(widget.oRegistro.dataHora!.toDate())}",
                              style: const TextStyle(fontSize: 14.0),
                            )),
                        const SizedBox(height: 50),
                        const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Como está seu humor?",
                            )),
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment.center,
                            child: retornaIconeHumor(widget.oRegistro.indiceHumor!,
                                tamanhoIcone: 80)),
                        const SizedBox(height: 25),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Como seu corpo reagiu?'),
                            Container(
                              height: 250,
                              width: double.infinity,
                              child: Scrollbar(
                                isAlwaysShown: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listaSintomasSelecionados!.length,
                                  itemBuilder: (_, int index) {
                                    return CheckboxListTile(
                                      enabled: false,
                                      activeColor: Colors.deepPurple,
                                      title: Text(listaSintomasSelecionados![index].descricao ??
                                          ""),
                                      value: true,
                                      onChanged: (bool? value) {
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        TextField(
                          enabled: false,
                          maxLines: 8,
                          controller: controladorSituacao,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: 'Descreva a situação',
                            labelStyle: const TextStyle(color: Colors.deepPurple),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(

                                  height: 45,
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.message,color: Colors.white),
                                    onPressed: (){
                                      Get.to(Comentario(oRegistro: widget.oRegistro, oUsuarioPaciente: widget.oUsuarioPaciente,oUsuarioTerapeuta: widget.oUsuarioTerapeuta,));
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      side: const BorderSide(color: Colors.white, width: 1),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    ),
                                    label: const Text("Comentários",style: TextStyle(color: Colors.white,fontSize: 16.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ));
  }
}
