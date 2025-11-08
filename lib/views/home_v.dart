import 'package:flutter/material.dart';
import 'package:user_sync/services/discovery_s.dart';
import 'package:user_sync/services/server_s.dart';
import 'package:user_sync/services/sync_s.dart';
import 'package:user_sync/services/user_s.dart';
import 'package:user_sync/views/widgets/show_toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userService = UserService();
  final _serverService = ServerService();
  final _discovery = DiscoveryService();
  final _sync = SyncService();

  bool isParent = false;
  String? connectedParentIp;
  final ValueNotifier<List<Map<String, dynamic>>> _users = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _userService.getAllUsers();
    _users.value = users;
  }

  Future<void> _createUser() async {
    final name = "User-${DateTime.now().millisecondsSinceEpoch}";
    await _userService.createUser(name);
    await _loadUsers();
  }

  Future<void> _connectToParent() async {
    final ip = await _discovery.findParent();
    if (ip == null) {
      showToast("Snap", "No parent found!");
    } else {
      setState(() => connectedParentIp = ip);
      await _sync.syncWithParent(ip);
      showToast("Success", "Connected & Synced with parent!");
      await _loadUsers(); // refresh after sync
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("POS Sync Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              title: const Text('Set as Parent'),
              value: isParent,
              onChanged: (val) async {
                if (val) {
                  if (await _serverService.startServer()) {
                    setState(() => isParent = true);
                    showToast("Success", "Parent mode enabled!");
                  } else {
                    showToast("Snap", "Parent already exists!");
                  }
                } else {
                  await _serverService.stopServer();
                  setState(() => isParent = false);
                  showToast("!!", "Parent mode disabled!");
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createUser,
              child: const Text("Create User"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _connectToParent,
              child: const Text("Connect to Parent"),
            ),
            if (connectedParentIp != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Connected to: $connectedParentIp",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Divider(height: 30),
            const Text(
              "User List:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _users,
                builder: (context, users, _) {
                  if (users.isEmpty) {
                    return const Center(child: Text("No users yet"));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${user['id']}')),
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text('Created: ${user['createdAt'] ?? ''}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
