import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('getAuthorizationBearer', () async {
    final service = RequestExtractorService();
    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/test'),
      headers: {
        'authorization': 'Bearer 123456testBearer',
      },
    );

    final token = service.getAuthorizationBearer(request);
    expect(token, '123456testBearer');
  });

  test('getBasicAuthorization', () async {
    final service = RequestExtractorService();
    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/test'),
      headers: {
        'authorization': 'Basic dGVzdEBtYWlsLmNvbTpteV9wYXNzd29yZDEyMzQ1',
      },
    );

    final userCredentials = service.getBasicAuthorization(request);
    expect(userCredentials.email, 'test@mail.com');
    expect(userCredentials.password, 'my_password12345');
  });
}
