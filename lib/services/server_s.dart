import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:user_sync/models/user_m.dart';
import 'package:user_sync/services/database_s.dart';
import 'package:user_sync/utils/logger.dart';

class ServerService {
  static final ServerService _instance = ServerService._internal();
  ServerService._internal();
  factory ServerService() => _instance;

  HttpServer? _server;

  /// Start the parent server
  Future<bool> startServer() async {
    if (_server != null) return false; // already running

    final app = Router();
    final db = DatabaseService();

    // GET endpoint: return all users
    app.get('/users', (Request req) async {
      final users = await db.getUsers();
      return Response.ok(jsonEncode(users.map((u) => u.toMap()).toList()), headers: {'Content-Type': 'application/json'});
    });

    // POST endpoint: sync users
    app.post('/sync', (Request req) async {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final List users = data['users'];
      await db.replaceAllUsers(users.map((e) => User.fromMap(e)).toList());
      return Response.ok(jsonEncode({'status': 'ok'}));
    });

    // Bind server to all interfaces
    _server = await io.serve(app.call, InternetAddress.anyIPv4, 8080);

    // Fetch all LAN IPv4 addresses (excluding loopback)
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    final lanIps = interfaces.expand((i) => i.addresses).where((addr) => !addr.isLoopback).map((addr) => addr.address).toList();

    if (lanIps.isEmpty) {
      logger.debug('Parent server running, but no LAN IP detected. Accessible only on this machine.');
    } else {
      for (var ip in lanIps) {
        logger.debug('Parent server running at http://$ip:${_server!.port}');
      }
    }

    return true;
  }

  /// Stop the parent server
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close(force: true);
      logger.debug('Parent server stopped.');
    }
    _server = null;
  }

  /// Whether the server is running
  bool get isRunning => _server != null;
}
