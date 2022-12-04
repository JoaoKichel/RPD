import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPensamento {
  String? emailUsuario;
  Timestamp? dataHora;
  int? indiceHumor;
  List? listaSintomas;
  String? descricaoSituacao;
  int? codTerapeuta;

  RegistroPensamento(
      {required this.emailUsuario,
      required this.dataHora,
      required this.indiceHumor,
      required this.descricaoSituacao,
      required this.listaSintomas,
      required this.codTerapeuta});

  RegistroPensamento.fromJson(Map<String, dynamic> json) {
    emailUsuario = json['emailUsuario'] ?? "";
    dataHora = json['dataHora'] ?? null;
    indiceHumor = json['indiceHumor'] ?? -1;
    listaSintomas = json['listaSintomas'] ?? [];
    descricaoSituacao = json['descricaoSituacao'] ?? "";
    codTerapeuta = json['codTerapeuta'] ?? -1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emailUsuario'] = emailUsuario;
    data['dataHora'] = dataHora;
    data['indiceHumor'] = indiceHumor;
    data['listaSintomas'] = listaSintomas != null ? listaSintomas!.toList() : [];
    data['descricaoSituacao'] = descricaoSituacao;
    data['codTerapeuta'] = codTerapeuta;
    return data;
  }
}
