class Hang {
  final int idHang;
  final String thongTin;
  final String thongTinChiTiet;
  final int diemToiDa;
  final int diemToiTheu;
  final int thoiGianThi;

  const Hang({
    required this.idHang,
    required this.thongTin,
    required this.thongTinChiTiet,
    required this.diemToiDa,
    required this.diemToiTheu,
    required this.thoiGianThi,
  });

  factory Hang.fromJson(Map<String, dynamic> json) {
    return Hang(
      idHang: json['idHang'],
      diemToiDa: json['diemtoida'],
      diemToiTheu: json['diemtoitheu'],
      thoiGianThi: json['thoigianthi'],
      thongTin: json['thongtin'],
      thongTinChiTiet: json['thongtinchitiet'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'idHang': idHang,
      'diemtoida': diemToiDa,
      'diemtoitheu': diemToiTheu,
      'thoigianthi': thoiGianThi,
      'thongtin': thongTin,
      'thongtinchitiet': thongTinChiTiet,
    };
  }

  @override
  String toString() {
    return 'Chang(idHang: $idHang, thongTin: $thongTin, thongTinChiTiet: $thongTinChiTiet, diemToiDa: $diemToiDa, diemToiTheu: $diemToiTheu, thoiGianThi: $thoiGianThi)';
  }
}
