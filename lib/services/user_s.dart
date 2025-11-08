import 'package:user_sync/models/user_m.dart';
import 'package:user_sync/services/database_s.dart';

class UserService {
  final _db = DatabaseService();

  Future<void> createUser(String name) async {
    final user = User(name: name, createdAt: DateTime.now().toIso8601String());
    await _db.insertUser(user);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final users = await _db.getUsers();
    // Return as a simple list of maps for the UI
    return users.map((u) => {'id': u.id, 'name': u.name, 'createdAt': u.createdAt}).toList();
  }

  Future<void> replaceAllUsers(List<User> users) async {
    await _db.replaceAllUsers(users);
  }
}
