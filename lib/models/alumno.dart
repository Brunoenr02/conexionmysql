class Alumno {
  final int? id;
  final String nombres;
  final String apellidos;
  final String codigo;
  final String direccion;
  final String numero;

  Alumno({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.codigo,
    required this.direccion,
    required this.numero,
  });

  // Convertir de JSON a objeto Alumno
  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] as int?,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      codigo: json['codigo'] as String,
      direccion: json['direccion'] as String,
      numero: json['numero'] as String,
    );
  }

  // Convertir de objeto Alumno a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'codigo': codigo,
      'direccion': direccion,
      'numero': numero,
    };
  }

  // Método para obtener el nombre completo
  String get nombreCompleto => '$nombres $apellidos';

  // Método copyWith para crear una copia con cambios
  Alumno copyWith({
    int? id,
    String? nombres,
    String? apellidos,
    String? codigo,
    String? direccion,
    String? numero,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      codigo: codigo ?? this.codigo,
      direccion: direccion ?? this.direccion,
      numero: numero ?? this.numero,
    );
  }

  @override
  String toString() {
    return 'Alumno{id: $id, nombres: $nombres, apellidos: $apellidos, codigo: $codigo, direccion: $direccion, numero: $numero}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno &&
        other.id == id &&
        other.nombres == nombres &&
        other.apellidos == apellidos &&
        other.codigo == codigo &&
        other.direccion == direccion &&
        other.numero == numero;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nombres.hashCode ^
        apellidos.hashCode ^
        codigo.hashCode ^
        direccion.hashCode ^
        numero.hashCode;
  }
}