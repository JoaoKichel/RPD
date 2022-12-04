class Sintoma{
  int? codigo;
  String? descricao;
  bool? marcado;

  Sintoma({required this.codigo,required this.descricao, this.marcado = false});

  Sintoma.fromJson(Map<String, dynamic> json) {
    codigo = json['codigo'] ?? 0;
    descricao = json['descricao'] ?? "";
    marcado = json['marcado'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['marcado'] = this.marcado;
    return data;
  }
}