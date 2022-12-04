import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projetovi/models/mensagem.dart';
import 'package:projetovi/models/registros_pensamento.dart';
import 'package:projetovi/models/usuario.dart';
import 'package:projetovi/pages/utils.dart';

class Comentario extends StatefulWidget {
  RegistroPensamento oRegistro;
  Usuario oUsuarioPaciente;
  Usuario oUsuarioTerapeuta;
  Comentario({Key? key, required this.oRegistro, required this.oUsuarioPaciente, required this.oUsuarioTerapeuta})
      : super(key: key);

  @override
  State<Comentario> createState() => _ComentarioState();
}

class _ComentarioState extends State<Comentario> {
  final user = FirebaseAuth.instance.currentUser!;
  bool bCarregando = false;
  List<Mensagem> listaComentarios = [];

  final controladorComentario = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    buscaComentarios();
    super.initState();
  }

  buscaComentarios() async {
    setState(() {
      bCarregando = true;
    });
    await FirebaseFirestore.instance
        .collection('comentarios')
        .where('cod_terapeuta', isEqualTo: widget.oUsuarioPaciente.codTerapeuta)
        .where('email_paciente', isEqualTo: '${widget.oUsuarioPaciente.email}')
        .orderBy('dataHora', descending: true)
        .get()
        .then((retornoComentarios) {
      listaComentarios = retornoComentarios.docs.map((docSnapshot) => Mensagem.fromJson(docSnapshot.data())).toList();
    }).catchError((erro) {
      erroPadrao(titulo: "Erro", mensagem: "Erro ao buscar os comentários.");
    });
    setState(() {
      bCarregando = false;
    });
  }

  gravaComentario() async {
    if (_formKey.currentState!.validate()) {
      Mensagem oComentario = Mensagem(
          mensagem: controladorComentario.text,
          dataHora: Timestamp.now(),
          cod_terapeuta: widget.oUsuarioPaciente.codTerapeuta,
          email_paciente: widget.oUsuarioPaciente.email);
      await FirebaseFirestore.instance.collection('comentarios').add(oComentario.toJson()).then((value) {
        controladorComentario.clear();
        FocusScope.of(context).unfocus();
        sucessoPadrao(titulo: 'Sucesso', mensagem: 'Comentário enviado com sucesso.');
        setState(() {
          listaComentarios.add(oComentario);
        });
      }).catchError((erro) {
        erroPadrao(titulo: 'Erro', mensagem: 'Erro ao gravar o comentário, tente novamente!');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.deepPurple,
          title: const Text('RPD - Comentários do Registro'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Paciente ${widget.oUsuarioPaciente.nome}",
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Data/Hora do Registro: ${formataData.format(widget.oRegistro.dataHora!.toDate())}",
                        style: const TextStyle(fontSize: 14.0),
                      )),
                  const SizedBox(height: 50),
                  listaComentarios.isNotEmpty
                      ? Container(
                          height: 300,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            child: ListView.builder(
                                itemCount: listaComentarios.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${listaComentarios[index].mensagem}',
                                          style: TextStyle(fontSize: 16.0),
                                          maxLines: 10,
                                        ),
                                        SizedBox(height: 10,),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(formataData.format(listaComentarios[index].dataHora!.toDate()),
                                                style: TextStyle(fontSize: 12.0), textAlign: TextAlign.end)),
                                      ],
                                    ),
                                  ));
                                }),
                          ),
                        )
                      : const Center(child: Text("Nenhum comentário encontrado.")),
                ],
              ),
              if (widget.oUsuarioTerapeuta.tipoAcesso == 1)
                Row(
                  children: [
                    Expanded(
                        child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Preenchimento obrigatório';
                          }
                          return null;
                        },
                        enabled: true,
                        maxLines: 5,
                        controller: controladorComentario,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Escreva seu comentário',
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          filled: true,
                        ),
                      ),
                    )),
                    IconButton(
                        onPressed: () async {
                          await gravaComentario();
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.deepPurple,
                        ))
                  ],
                ),
            ],
          ),
        ));
  }
}
