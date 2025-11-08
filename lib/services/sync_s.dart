import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:user_sync/data/remote/controller/network_c.dart';
import 'package:user_sync/models/user_m.dart';
import 'package:user_sync/services/database_s.dart';
import 'package:user_sync/utils/logger.dart';

class SyncService {
  final DatabaseService _db = DatabaseService();
  Timer? _pollingTimer;

  /// ------------------------------
  /// Pull: Sync local DB with parent at [parentIp]
  /// ------------------------------
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

        // Map to User objects
        final users = data.map((e) => User.fromMap(e)).toList();
        logger.debug("Received ${users.length} user(s) from parent.");

        // Merge: only add new users
        final existingUsers = await _db.getUsers();
        final existingIDs = existingUsers.map((u) => u.id).toSet();
        logger.debug("Existing id: $existingIDs");

        final newUsers = users.where((u) => !existingIDs.contains(u.id)).toList();

        logger.debug("Existing users: ${existingUsers.length}, New users: ${newUsers.length}, Total users: ${existingUsers.length + newUsers.length}");

        for (var user in newUsers) {
          await _db.insertUser(user);
        }

        logger.debug('Local DB merged ${newUsers.length} new user(s) from parent.');
      } else {
        logger.debug('Failed to fetch users from parent. Status: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      logger.error('Error syncing with parent', e, e.stackTrace);
    } catch (e) {
      logger.error('Unhandled error syncing with parent', e);
    }
  }

  /// ------------------------------
  /// Push: Send local users to parent
  /// ------------------------------
  Future<void> pushToParent(String parentIp, [List<User>? usersToPush]) async {
    final url = 'http://$parentIp:8080/sync';
    final users = usersToPush ?? await _db.getUsers();
    final body = {'users': users.map((u) => u.toMap()).toList()};

    try {
      logger.debug('Pushing ${users.length} user(s) to parent: $url');
      final response = await networkControllerInstance.request(url: url, method: Method.POST, params: body);

      if (response != null && response.statusCode == 200) {
        logger.debug('Successfully pushed ${users.length} user(s) to parent.');
      } else {
        logger.debug('Failed to push users. Status: ${response?.statusCode}');
      }
    } catch (e) {
      logger.error('Error pushing users to parent', e);
    }
  }

  /// ------------------------------
  /// Start periodic polling from parent
  /// ------------------------------
  void startPolling(String parentIp, {int intervalSeconds = 5, Function? onPoll}) {
    stopPolling(); // cancel existing timer if any

    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      await syncWithParent(parentIp);
      onPoll?.call();
    });

    logger.debug('Started polling parent at $parentIp every $intervalSeconds seconds.');
  }

  /// Stop periodic polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    logger.debug('Stopped polling parent.');
  }
}
