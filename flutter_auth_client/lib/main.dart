import 'package:flutter/material.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/profile/profile_page.dart';
import 'features/admin/admin_page.dart';

void main() {
  final storage = TokenStorage();
  final api = ApiClient(storage);
  final auth = AuthRepository(api, storage);
  runApp(AuthDemoApp(auth: auth));
}

class AuthDemoApp extends StatelessWidget {
  final AuthRepository auth;
  const AuthDemoApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Backend Mastery Auth',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    routes: {
      '/': (_) => LoginPage(auth: auth),
      '/register': (_) => RegisterPage(auth: auth),
      '/profile': (_) => ProfilePage(auth: auth),
      '/admin': (_) => AdminPage(auth: auth),
    },
  );
}
