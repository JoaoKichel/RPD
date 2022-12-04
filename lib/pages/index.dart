import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:projetovi/models/registros_pensamento.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/registro.dart';
import 'package:projetovi/pages/selecao_pacientes.dart';
import 'package:projetovi/pages/utils.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  Usuario? oUsuario;
  final user = FirebaseAuth.instance.currentUser!;
  bool bCarregando = true;
  RegistroPensamento? oRegistroPensamento;
  double iHumorSelecionado = 2;

  final controladorSituacao = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregaDadosUsuario(user).then((retornoUsuario) {
      oUsuario = retornoUsuario;
      setState(() {
        bCarregando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,
      drawer: retornaDrawer(oUsuario: oUsuario, user: user),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.deepPurple,
        title: oUsuario?.tipoAcesso == 1 ? Text("RPD - Área do Terapeuta") : Text('RPD - Área do Paciente'),
      ),
      body: bCarregando
          ? const Center(child: CircularProgressIndicator())
          : oUsuario?.tipoAcesso == 1 ? SelecaoPacientes(oUsuario: oUsuario!) : SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Como está seu humor?',
                      textAlign: TextAlign.center,
                    ),
                    Center(
                        child: RatingBar.builder(
                      wrapAlignment: WrapAlignment.center,
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 50,
                      glowColor: Colors.deepPurple,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, int index) {
                        return retornaIconeHumor(index + 1);
                      },
                      onRatingUpdate: (rating) {
                        iHumorSelecionado = rating;
                      },
                    )),
                    const SizedBox(height: 25),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Como seu corpo reagiu?'),
                        Container(
                          height: 300,
                          width: double.infinity,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: listaSintomas.length,
                              itemBuilder: (_, int index) {
                                return CheckboxListTile(
                                  activeColor: Colors.deepPurple,
                                  title: Text(listaSintomas[index].descricao ?? ""),
                                  value: listaSintomas[index].marcado,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      listaSintomas[index].marcado = value!;
                                    });
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
                      maxLines: 10,
                      controller: controladorSituacao,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        //hintText: 'Descrição',
                        labelText: 'Descreva a situação',
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: TextButton(
                          onPressed: () async {
                            try {
                              oRegistroPensamento = RegistroPensamento(
                                  emailUsuario: oUsuario!.email!,
                                  dataHora: Timestamp.fromDate(DateTime.now()),
                                  indiceHumor: iHumorSelecionado.toInt(),
                                  descricaoSituacao: controladorSituacao.text,
                                  listaSintomas: listaSintomas
                                      .where((element) => (element.marcado ?? false))
                                      .toList().map((e) => e.codigo!).toList(),
                                  codTerapeuta: oUsuario!.codTerapeuta);
                              await FirebaseFirestore.instance
                                  .collection('pensamentos')
                                  .add(oRegistroPensamento!.toJson());
                              sucessoPadrao(titulo: 'Sucesso',mensagem: "Registro gravado com sucesso");
                              await Get.to(() => Registro(oRegistro: oRegistroPensamento!,oUsuarioPaciente: oUsuario!,oUsuarioTerapeuta: oUsuario!,));

                              setState(() {
                                oRegistroPensamento = null;
                                controladorSituacao.clear();
                                listaSintomas.forEach((element) {
                                  element.marcado = false;
                                });
                                iHumorSelecionado = 3;
                              });
                            } catch (erro) {
                              Get.snackbar("Erro", "Erro na gravação do pensamento, tente novamente!",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  icon: const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                  ));
                            }
                          },
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(Colors.deepPurple[400]),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: const BorderSide(width: 1, color: Colors.deepPurple),
                                ),
                              ),
                              textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
                              backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                          child: const Text(
                            "Registrar",
                            style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
