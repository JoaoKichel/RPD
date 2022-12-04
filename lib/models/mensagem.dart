import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem{
  String? mensagem;
  int? cod_terapeuta;
  String? email_paciente;
  Timestamp? dataHora;

  Mensagem(
      {required this.mensagem,
        required this.dataHora,
      required this.cod_terapeuta,
      required this.email_paciente});

  Mensagem.fromJson(Map<String, dynamic> json) {
    mensagem = json['mensagem'] ?? "";
    cod_terapeuta = json['cod_terapeuta'] ?? null;
    email_paciente = json['email_paciente'] ?? "";
    dataHora = json['dataHora'] ?? null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mensagem'] = mensagem;
    data['cod_terapeuta'] = cod_terapeuta;
    data['email_paciente'] = email_paciente;
    data['dataHora'] = dataHora;
    return data;
  }
}