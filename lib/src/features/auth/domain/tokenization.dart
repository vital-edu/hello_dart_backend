import 'dart:convert';

class Tokenization {
  final String accessToken;
  final String refreshToken;

  Tokenization({required this.accessToken, required this.refreshToken});

  factory Tokenization.fromMap(Map<String, dynamic> json) {
    return Tokenization(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, String> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  factory Tokenization.fromJson(String source) {
    return Tokenization.fromMap(json.decode(source));
  }

  String toJson() => json.encode(toMap());
}
