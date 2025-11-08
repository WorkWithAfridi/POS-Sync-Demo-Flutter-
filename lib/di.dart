import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:user_sync/data/local/local_storage.dart';
import 'package:user_sync/data/remote/controller/network_c.dart';
import 'package:user_sync/utils/logger.dart';

class DependencyInjector {
  Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _configureControllers();
    _configureLocalStorage();
  }

  void _configureControllers() {
    NetworkController networkController = GetIt.instance.registerSingleton<NetworkController>(NetworkController());
    networkController.init();
    logger.debug("Custom controllers initialized");
  }

  void _configureLocalStorage() {
    LocalStorage().init();
    LocalStorage localStorage = GetIt.instance.registerSingleton<LocalStorage>(LocalStorage());
    localStorage.init();
    logger.debug("Local storage initialized");
  }
}
