import 'package:flutter/material.dart';
import '../auth/data/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  final AuthRepository auth;
  const ProfilePage({super.key, required this.auth});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? me;
  String? error;

  @override
  void initState() {
    super.initState();
    final signedInUser = widget.auth.currentUser;
    if (signedInUser != null) {
      me = signedInUser;
    } else {
      load();
    }
  }

  Future<void> load() async {
    try {
      final value = await widget.auth.me();
      if (mounted) setState(() => me = value);
    } catch (e) {
      if (mounted) {
        setState(() => error = widget.auth.friendlyErrorMessage(e, action: 'profile'));
      }
    }
  }

  Future<void> logout() async {
    try {
      await widget.auth.logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.auth.friendlyErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = me;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: error != null
            ? Center(child: Text(error!, textAlign: TextAlign.center))
            : user == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${user['name']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Email: ${user['email']}'),
                      Text('Role: ${user['role']}'),
                      if (user['role'] == 'ADMIN') ...[
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/admin'),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Open admin panel'),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
