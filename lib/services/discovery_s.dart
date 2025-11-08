import 'dart:io';

import 'package:user_sync/utils/logger.dart';

class DiscoveryService {
  /// Scans local network for parent server
  Future<String?> findParent() async {
    final myIp = await _getLocalIp();
    if (myIp == null) {
      logger.debug('Cannot determine local IP.');
      return null;
    }

    // Get subnet, e.g., 192.168.0
    final subnet = myIp.split('.').sublist(0, 3).join('.');
    logger.debug('Scanning subnet $subnet.x for parent server...');

    for (int i = 2; i < 255; i++) {
      final ip = '$subnet.$i';
      try {
        logger.debug('Trying $ip:8080...');
        final socket = await Socket.connect(ip, 8080, timeout: const Duration(milliseconds: 200));
        socket.destroy();
        logger.debug('Parent found at $ip');
        return ip;
      } catch (e) {
        logger.debug('No server at $ip: $e');
      }
    }

    logger.debug('No parent server found on local network.');
    return null;
  }

  /// Get device’s local IP on Wi-Fi
  Future<String?> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return null;
  }
}
