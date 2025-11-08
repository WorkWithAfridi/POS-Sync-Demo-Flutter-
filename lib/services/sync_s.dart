import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:user_sync/data/remote/controller/network_c.dart';
import 'package:user_sync/models/user_m.dart';
import 'package:user_sync/services/database_s.dart';
import 'package:user_sync/utils/logger.dart';

class SyncService {
  final DatabaseService _db = DatabaseService();

  /// Sync local DB with parent at [parentIp]
  Future<void> syncWithParent(String parentIp) async {
    final url = 'http://$parentIp:8080/users';
    try {
      logger.debug('Fetching users from parent: $url');

      final response = await networkControllerInstance.request(url: url, method: Method.GET);

      if (response != null && response.statusCode == 200) {
        List<dynamic> data;

        // Handle both String and already-parsed JSON
        if (response.data is String) {
          data = jsonDecode(response.data as String);
        } else if (response.data is List) {
          data = response.data as List<dynamic>;
        } else {
          throw Exception('Unexpected response type: ${response.data.runtimeType}');
        }

        // Map to User objects and replace local DB
        final users = data.map((e) => User.fromMap(e)).toList();
        await _db.replaceAllUsers(users);

        logger.debug('Local database synced with parent: ${users.length} users.');
      } else {
        logger.debug('Failed to fetch users from parent. Status: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      logger.error('Error syncing with parent', e, e.stackTrace);
    } catch (e) {
      logger.error('Unhandled error syncing with parent', e);
    }
  }

  /// Push local users to parent (optional, for two-way sync)
  Future<void> pushToParent(String parentIp) async {
    final url = 'http://$parentIp:8080/sync';
    final users = await _db.getUsers();
    final body = {'users': users.map((u) => u.toMap()).toList()};

    try {
      logger.debug('Pushing local users to parent: $url');
      final response = await networkControllerInstance.request(url: url, method: Method.POST, params: body);

      if (response != null && response.statusCode == 200) {
        logger.debug('Successfully pushed local users to parent.');
      } else {
        logger.debug('Failed to push users. Status: ${response?.statusCode}');
      }
    } catch (e) {
      logger.error('Error pushing users to parent', e);
    }
  }
}
