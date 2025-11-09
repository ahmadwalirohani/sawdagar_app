import 'package:afghan_bazar/models/weekly_model.dart';

class Weekly {
  Weekly({required this.data});

  Weekly.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(WeeklyModel.fromJson(v));
      });
    }
  }
  late List<WeeklyModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
