import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_exceptions.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class MockAuthService extends AuthService {
  final String? _token;
  MockAuthService({String? token}) : _token = token;

  @override
  Future<String?> getToken() async => _token;
}

void main() {
  group('ApiClient Tests', () {
    test('GET request successfully parses UTF-8 JSON', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer test_token_xyz');

        final responseBody = jsonEncode({
          'id': 1,
          'name': 'Nguyễn Văn An',
          'description': 'Tiếng Việt có dấu đầy đủ',
        });
        return http.Response.bytes(
          utf8.encode(responseBody),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        authService: MockAuthService(token: 'test_token_xyz'),
      );

      final result = await apiClient.get('/api/test/profile');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], 'Nguyễn Văn An');
      expect(result['description'], 'Tiếng Việt có dấu đầy đủ');
    });

    test('POST request sends JSON body properly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        final decoded = jsonDecode(request.body);
        expect(decoded['key'], 'giá trị');

        return http.Response.bytes(
          utf8.encode(jsonEncode({'status': 'ok'})),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        authService: MockAuthService(token: null),
      );

      final result = await apiClient.post('/api/test/submit', body: {'key': 'giá trị'});
      expect(result['status'], 'ok');
    });

    test('Throws UnauthorizedException on 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'message': 'Phiên đăng nhập hết hạn'})),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, authService: MockAuthService());

      expect(
        () => apiClient.get('/api/protected'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('Throws ForbiddenException on 403', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'message': 'Không có quyền truy cập'})),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, authService: MockAuthService());

      expect(
        () => apiClient.get('/api/admin/system'),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('Throws ResourceNotFoundException on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'message': 'Không tìm thấy tài nguyên'})),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, authService: MockAuthService());

      expect(
        () => apiClient.get('/api/missing/123'),
        throwsA(isA<ResourceNotFoundException>()),
      );
    });

    test('Throws ApiException with status 500 on server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'message': 'Lỗi máy chủ nội bộ'})),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, authService: MockAuthService());

      expect(
        () => apiClient.get('/api/crash'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('ApiClient.instance returns singleton instance', () {
      final a = ApiClient();
      final b = ApiClient.instance;
      expect(identical(a, b), isTrue);
    });

    test('ETag 304 returns cached data without re-decoding payload', () async {
      int serverCalls = 0;
      final mockClient = MockClient((request) async {
        serverCalls++;
        if (request.headers['If-None-Match'] == '"etag_v1"') {
          return http.Response('', 304);
        }
        return http.Response.bytes(
          utf8.encode(jsonEncode({'data': 'phiên_bản_1'})),
          200,
          headers: {'etag': '"etag_v1"', 'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, authService: MockAuthService());

      // Lần 1: Nhận 200 OK và ETag
      final res1 = await apiClient.get('/api/cached-resource');
      expect(res1['data'], 'phiên_bản_1');
      expect(serverCalls, 1);

      // Lần 2: Server trả về 304 Not Modified, client tự lấy data từ cache
      final res2 = await apiClient.get('/api/cached-resource');
      expect(res2['data'], 'phiên_bản_1');
      expect(serverCalls, 2);
    });

    test('Request Deduplication merges concurrent identical GET requests', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return http.Response.bytes(
          utf8.encode(jsonEncode({'count': requestCount})),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, authService: MockAuthService());

      // Bắn 3 requests đồng thời
      final futures = await Future.wait([
        apiClient.get('/api/duplicate-test'),
        apiClient.get('/api/duplicate-test'),
        apiClient.get('/api/duplicate-test'),
      ]);

      // Server chỉ nhận duy nhất 1 cuộc gọi mạng thực sự
      expect(requestCount, 1);
      expect(futures[0]['count'], 1);
      expect(futures[1]['count'], 1);
      expect(futures[2]['count'], 1);
    });
  });
}
