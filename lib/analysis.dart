import 'package:afghan_bazar/models/analysis_model.dart';

class Analysis {
  Analysis({required this.data});

  Analysis.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(AnalysisModel.fromJson(v));
      });
    }
  }
  late List<AnalysisModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
