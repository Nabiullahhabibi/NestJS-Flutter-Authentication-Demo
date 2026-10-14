import 'package:flutter/material.dart';
import '../auth/data/auth_repository.dart';

class AdminPage extends StatefulWidget {
  final AuthRepository auth;
  const AdminPage({super.key, required this.auth});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? error;
  final Set<int> updatingUserIds = {};

  bool get isAdmin => widget.auth.currentUser?['role'] == 'ADMIN';
  int? get currentUserId => widget.auth.currentUser?['id'] as int?;

  @override
  void initState() {
    super.initState();
    if (isAdmin) {
      loadUsers();
    } else {
      loading = false;
      error = 'Only administrators can view the user list.';
    }
  }

  Future<void> loadUsers() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.auth.adminUsers();
      print("all the user: ${result}");
      final loadedUsers = result
          .whereType<Map>()
          .map((user) => Map<String, dynamic>.from(user))
          .toList();
      if (mounted) setState(() => users = loadedUsers);
    } catch (e) {
      if (mounted) {
        setState(() => error = widget.auth.friendlyErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> updateRole(Map<String, dynamic> user, String role) async {
    final id = user['id'];
    if (id is! int || role == user['role']) return;

    setState(() => updatingUserIds.add(id));
    try {
      final updatedUser = await widget.auth.updateUserRole(id, role);
      if (!mounted) return;
      setState(() {
        users = users
            .map((item) => item['id'] == id ? updatedUser : item)
            .toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${user['name']} is now $role.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.auth.friendlyErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => updatingUserIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Users'),
        actions: [
          IconButton(
            tooltip: 'Refresh users',
            onPressed: loading ? null : loadUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    if (isAdmin)
                      FilledButton(
                        onPressed: loadUsers,
                        child: const Text('Try again'),
                      ),
                  ],
                ),
              ),
            )
          : users.isEmpty
          ? const Center(child: Text('No users found.'))
          : RefreshIndicator(
              onRefresh: loadUsers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final id = user['id'] as int?;
                  final role = user['role'] as String? ?? 'USER';
                  final isSelf = id == currentUserId;
                  final updating = id != null && updatingUserIds.contains(id);

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(_initial(user['name'] as String?)),
                      ),
                      title: Text(user['name'] as String? ?? 'Unnamed user'),
                      subtitle: Text(user['email'] as String? ?? ''),
                      trailing: SizedBox(
                        width: 132,
                        child: updating
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : DropdownButton<String>(
                                value: role == 'ADMIN' ? 'ADMIN' : 'USER',
                                isExpanded: true,
                                onChanged: isSelf || id == null
                                    ? null
                                    : (nextRole) {
                                        if (nextRole != null) {
                                          updateRole(user, nextRole);
                                        }
                                      },
                                items: const [
                                  DropdownMenuItem(
                                    value: 'USER',
                                    child: Text('User'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ADMIN',
                                    child: Text('Admin'),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }
}
