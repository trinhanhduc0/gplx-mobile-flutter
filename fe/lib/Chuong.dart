
class Chuong {
  final int idChuong;
  final String thongTinChuong;

  Chuong({
    required this.idChuong,
    required this.thongTinChuong,
  });

  factory Chuong.fromJson(Map<String, dynamic> json) {
    return Chuong(
      idChuong: json['idChuong'],
      thongTinChuong: json['thongTinChuong'],
    );
  }
}
