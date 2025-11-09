import 'package:afghan_bazar/models/radio_program_model.dart';

class RadioProgram {
  RadioProgram({required this.data});

  RadioProgram.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(RadioProgramModel.fromJson(v));
      });
    }
  }
  late List<RadioProgramModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
