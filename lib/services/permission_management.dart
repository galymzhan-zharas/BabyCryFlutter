import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class PermissionManagement{
  static Future<bool> storagePermission() async{
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }




















  //---------------------------------------------------------------
  static Future<bool> recordingPermission() async{
    print('Requesting recording permission...');
    final status = await Permission.microphone.request();
    print('Recording permission status: $status');
    return status == PermissionStatus.granted;
  }


}

