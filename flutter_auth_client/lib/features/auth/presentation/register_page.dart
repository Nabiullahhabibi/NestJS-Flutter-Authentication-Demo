import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class RegisterPage extends StatefulWidget {
  final AuthRepository auth;

  const RegisterPage({super.key, required this.auth});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    // Validate all fields before making the API request.
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await widget.auth.register(
        name.text.trim(),
        email.text.trim(),
        password.text,
      );

      // Navigate only if registration and token storage succeed.
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.auth.friendlyErrorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create an account',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Name must contain at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final emailValue = value?.trim() ?? '';

                      if (emailValue.isEmpty ||
                          !RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(emailValue)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: password,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!loading) submit();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                      helperText: 'At least 8 characters',
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Password must contain at least 8 characters';
                      }

                      if (value.length > 72) {
                        return 'Password cannot exceed 72 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: loading ? null : submit,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
