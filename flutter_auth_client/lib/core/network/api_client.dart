import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  // Android emulator: http://10.0.2.2:3000
  // Physical phone: http://YOUR_COMPUTER_LAN_IP:3000
  final TokenStorage storage;
  late final Dio dio;
  bool _refreshing = false;

  
  ApiClient(this.storage) {
  // Android emulator default. For a physical device, run with
  // --dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:3000.
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.103:3000',
  );

  dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;

        final isPublicAuthRoute =
            path.endsWith('/auth/register') ||
            path.endsWith('/auth/login') ||
            path.endsWith('/auth/refresh');

        if (isPublicAuthRoute) {
          handler.next(options);
          return;
        }

        try {
          final token = await storage.accessToken;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        } catch (e) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: e,
              message: 'Could not read the stored access token.',
            ),
          );
        }
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            !_refreshing &&
            !error.requestOptions.path.contains('/auth/')) {
          _refreshing = true;

          try {
            final refresh = await storage.refreshToken;

            if (refresh != null && refresh.isNotEmpty) {
              final response = await dio.post(
                '/auth/refresh',
                data: {'refreshToken': refresh},
              );

              final newAccessToken =
                  response.data['accessToken'] as String;
              final newRefreshToken =
                  response.data['refreshToken'] as String;

              await storage.save(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              final request = error.requestOptions;
              request.headers['Authorization'] =
                  'Bearer $newAccessToken';

              final retry = await dio.fetch(request);
              handler.resolve(retry);
              return;
            }
          } catch (_) {
            try {
              await storage.clear();
            } catch (_) {
              // Storage may itself be inaccessible.
            }
          } finally {
            _refreshing = false;
          }
        }

        handler.next(error);
      },
    ),
  );
}

}
