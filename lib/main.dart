import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:user_sync/di.dart';
import 'package:user_sync/views/home_v.dart';

void main(List<String> args) {
  DependencyInjector().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'POS Sync Demo',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const HomePage(),
      ),
    );
  }
}
