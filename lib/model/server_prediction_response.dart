// To parse this JSON data, do
//
//     final predictResponse = predictResponseFromJson(jsonString);

import 'dart:convert';

PredictResponse predictResponseFromJson(String str) => PredictResponse.fromJson(json.decode(str));

String predictResponseToJson(PredictResponse data) => json.encode(data.toJson());

class PredictResponse {
  PredictResponse({
    required this.confidence,
    required this.results,
  });

  double confidence;
  int results;

  factory PredictResponse.fromJson(Map<String, dynamic> json) => PredictResponse(
    confidence: json["confidence"].toDouble(),
    results: json["results"],
  );

  Map<String, dynamic> toJson() => {
    "confidence": confidence,
    "results": results,
  };
}
