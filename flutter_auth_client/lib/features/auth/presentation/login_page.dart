import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget { final AuthRepository auth; const LoginPage({super.key, required this.auth});
  @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(); final password = TextEditingController(); bool loading = false;
  Future<void> submit() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await widget.auth.login(email.text.trim(), password.text);
      if (mounted) Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.auth.friendlyErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  @override void dispose(){email.dispose(); password.dispose(); super.dispose();}
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Login')), body: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [TextField(controller: email, decoration: const InputDecoration(labelText:'Email')), TextField(controller: password, obscureText:true, decoration: const InputDecoration(labelText:'Password')), const SizedBox(height:20), FilledButton(onPressed: loading ? null : submit, child: Text(loading ? 'Loading...' : 'Login')), TextButton(onPressed: ()=>Navigator.pushNamed(context,'/register'), child: const Text('Create account'))])));
}
