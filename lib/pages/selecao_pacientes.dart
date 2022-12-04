import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/registros_do_usuario.dart';
import 'package:projetovi/pages/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SelecaoPacientes extends StatefulWidget {
  Usuario oUsuario;
  SelecaoPacientes({Key? key, required this.oUsuario}) : super(key: key);

  @override
  State<SelecaoPacientes> createState() => _SelecaoPacientesState();
}

class _SelecaoPacientesState extends State<SelecaoPacientes> {
  bool bCarregando = true;
  List<Usuario> listaPacientes = [];

  Future carregaPacientes() async {
    return await FirebaseFirestore.instance
        .collection('usuarios')
        .where('tipo_acesso', isEqualTo: 2)
        .where('cod_terapeuta', isEqualTo: widget.oUsuario.codTerapeuta)
        .orderBy('nome')
        .get(const GetOptions(source: Source.server))
        .then((retornoUsuario) {
      return retornoUsuario.docs.map((docSnapshot) => Usuario.fromJson(docSnapshot.data())).toList();
    }).catchError((erro) {
      erroPadrao(titulo: "Erro", mensagem: "Erro ao buscar os dados do Usuário.");
    });
  }

  @override
  void initState() {
    carregaPacientes().then((oPacientes) {
      listaPacientes = oPacientes;
      setState(() {
        bCarregando = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return bCarregando
        ? Container(color: Colors.white, child: const Center(child: CircularProgressIndicator()))
        : Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${widget.oUsuario.nome}",
                              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          Text("CRP: ${widget.oUsuario.codTerapeuta}", style: const TextStyle(fontSize: 16.0)),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(),
                      const Text("Pacientes:",
                          style: TextStyle(fontSize: 18.0, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                            itemCount: listaPacientes.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.person,
                                    color: Colors.deepPurple,
                                  ),
                                  title: Text(listaPacientes[index].nome!),
                                  onTap: () async {
                                    await Get.to(() => RegistrosDoUsuario(
                                        oUsuarioPaciente: listaPacientes[index], oUsuarioTerapeuta: widget.oUsuario));
                                  },
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            child: TextButton.icon(
                              icon: Icon(Icons.qr_code, color: Colors.deepPurple),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('QRCode do Terapeuta'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 300,
                                          width: double.maxFinite,
                                          child: QrImage(
                                            data: widget.oUsuario.codTerapeuta.toString(),
                                            version: QrVersions.auto,
                                            size: 300,
                                            gapless: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text(
                                          "Fechar",
                                          style: TextStyle(color: Colors.deepPurple),
                                        ),
                                        onPressed: () => Get.back(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                side: BorderSide(color: Colors.deepPurple, width: 1),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                              ),
                              label: Text("Gerar QRCode", style: TextStyle(color: Colors.deepPurple, fontSize: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
