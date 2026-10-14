# Flutter Auth Client

Flutter client for the NestJS Backend Mastery authentication demo.

## Concepts implemented

- REST API client with Dio
- Login and registration
- Secure access/refresh token storage with `flutter_secure_storage`
- Bearer Authorization header
- Automatic refresh after HTTP 401
- Retry of the failed request after refresh
- Protected profile screen
- Admin-only API call
- Logout and local credential clearing

## Run

1. Run the NestJS API first.
2. Run `flutter pub get`.
3. Android emulator: keep `http://10.0.2.2:3000`.
4. Physical Android device: change `baseUrl` in `lib/core/network/api_client.dart` to your computer's LAN IP, e.g. `http://192.168.1.10:3000`.
5. For production use HTTPS.

## Android local HTTP

For local development only, Android may require cleartext HTTP to be allowed depending on your project configuration. Prefer HTTPS for production.
