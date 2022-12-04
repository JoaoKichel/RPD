class Usuario {
  String? nome;
  String? email;
  int? codTerapeuta;
  int? tipoAcesso;

  Usuario({this.nome, this.email, this.codTerapeuta, this.tipoAcesso});

  Usuario.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    email = json['email'];
    codTerapeuta = json['cod_terapeuta'];
    tipoAcesso = json['tipo_acesso'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['email'] = this.email;
    data['cod_terapeuta'] = this.codTerapeuta;
    data['tipo_acesso'] = this.tipoAcesso;
    return data;
  }
}