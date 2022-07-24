import 'dart:convert' as convert;

String jsonEncode(dynamic object) => convert.jsonEncode(
      object,
      toEncodable: (nonEncodable) => nonEncodable is DateTime
          ? nonEncodable.toIso8601String()
          : throw UnsupportedError('Cannot convert to JSON: $nonEncodable'),
    );
