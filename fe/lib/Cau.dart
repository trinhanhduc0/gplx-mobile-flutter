
class Cau {
  int idCau;
  int stt;
  int idChuong;
  List<Dapan> dapans;
  List<HangCau> hangCaus;
  Ttcau ttcaus;

  Cau({
    required this.idCau,
    required this.stt,
    required this.idChuong,
    required this.dapans,
    required this.hangCaus,
    required this.ttcaus,
  });

  factory Cau.fromJson(Map<String, dynamic> json) {
    return Cau(
      idCau: json['idCau'],
      stt: json['stt'],
      idChuong: json['idChuong'],
      dapans: List<Dapan>.from(json['dapans'].map((x) => Dapan.fromJson(x))),
      hangCaus: List<HangCau>.from(json['hangCaus'].map((x) => HangCau.fromJson(x))),
      ttcaus: Ttcau.fromJson(json['ttcaus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCau': idCau,
      'stt': stt,
      'idChuong': idChuong,
      'dapans': dapans.map((dapan) => dapan.toJson()).toList(),
      'hangCaus': hangCaus.map((hangCau) => hangCau.toJson()).toList(),
      'ttcaus': ttcaus.toJson(),
    };
  }
}

class Dapan {
  String dapan1;
  bool dapandung;
  int iddapan;

  Dapan({
    required this.iddapan,
    required this.dapan1,
    required this.dapandung,
  });

  factory Dapan.fromJson(Map<String, dynamic> json) {
    return Dapan(
      iddapan: json['idDapan'],
      dapan1: json['dapan1'],
      dapandung: json['dapandung'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDapan': iddapan,
      'dapan1': dapan1,
      'dapandung': dapandung,
    };
  }
}

class HangCau {
  int idHang;

  HangCau({
    required this.idHang,
  });

  factory HangCau.fromJson(Map<String, dynamic> json) {
    return HangCau(
      idHang: json['idHang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idHang': idHang,
    };
  }
}

class Ttcau {
  String goiy;
  bool diemliet;
  int idTtcau;
  String cauhoi;
  String hinhcauhoi;

  Ttcau({
    required this.goiy,
    required this.diemliet,
    required this.idTtcau,
    required this.cauhoi,
    required this.hinhcauhoi,
  });

  factory Ttcau.fromJson(Map<String, dynamic> json) {
    return Ttcau(
      goiy: json['goiy'],
      diemliet: json['diemliet'],
      idTtcau: json['idTtcau'],
      cauhoi: json['cauhoi'],
      hinhcauhoi: json['hinhcauhoi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goiy': goiy,
      'diemliet': diemliet,
      'idTtcau': idTtcau,
      'cauhoi': cauhoi,
      'hinhcauhoi': hinhcauhoi,
    };
  }
}
