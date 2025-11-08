import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(String title, String description, {Color? backgroundColor, Icon? icon}) {
  toastification.show(
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    description: Text(description, style: const TextStyle(color: Colors.white)),
    backgroundColor: backgroundColor ?? Colors.blueAccent,
    icon: icon ?? const Icon(Icons.warning_amber_outlined, size: 28, color: Colors.white),
    autoCloseDuration: const Duration(seconds: 4),
    showProgressBar: true,
    closeButton: ToastCloseButton(
      buttonBuilder: (context, onClose) {
        return IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 16),
          onPressed: onClose,
        );
      },
    ),
    borderSide: BorderSide(color: Colors.white, width: 0),
    alignment: Alignment.topCenter,
    progressBarTheme: ProgressIndicatorThemeData(color: Colors.white, strokeWidth: .5, linearTrackColor: Colors.transparent),
  );
}
