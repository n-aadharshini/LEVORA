import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to continue'),
        ),
      );
    }

    return false;
  }
}
