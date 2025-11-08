import 'package:user_sync/models/user_m.dart';
import 'package:user_sync/services/database_s.dart';
import 'package:user_sync/services/sync_s.dart';
import 'package:user_sync/utils/logger.dart';

class UserService {
  final DatabaseService _db = DatabaseService();
  final SyncService _sync = SyncService();

  /// Create a user locally and push to parent if connected
  Future<void> createUser(String name, {String? parentIp}) async {
    final user = User(name: name, createdAt: DateTime.now().toIso8601String());
    await _db.insertUser(user);
    logger.debug('Created user locally: ${user.name}');

    if (parentIp != null) {
      await _sync.pushToParent(parentIp, [user]); // push this user immediately
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final users = await _db.getUsers();
    return users.map((u) => {'id': u.id, 'name': u.name, 'createdAt': u.createdAt}).toList();
  }

  Future<void> replaceAllUsers(List<User> users) async {
    await _db.replaceAllUsers(users);
  }
}
