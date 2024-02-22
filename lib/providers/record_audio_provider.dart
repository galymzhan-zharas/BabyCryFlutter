import 'dart:core';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:record_with_play/services/permission_management.dart';
import 'package:record_with_play/services/storage_management.dart';
import 'package:record_with_play/services/toast_services.dart';
import 'package:dio/dio.dart';

class RecordAudioProvider extends ChangeNotifier{
  final _record = AudioRecorder();
  bool _isRecording = false;
  String _afterRecordingFilePath = '';
  String? _audioFilePath;
  bool get isRecording => _isRecording;
  String get recordedFilePath => _afterRecordingFilePath;

  clearOldData(){
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  recordVoice()async{
    print('Recording voice...');
    final _isPermitted = (await PermissionManagement.recordingPermission()) && (await PermissionManagement.storagePermission());

    if(!_isPermitted) return;

    if(!(await _record.hasPermission())) return;

    final _voiceDirPath = await StorageManagement.getAudioDir;
    final _voiceFilePath = StorageManagement.createRecordAudioPath(dirPath: _voiceDirPath, fileName: 'audio_message');

    await _record.start(const RecordConfig(), path: _voiceFilePath);
    _isRecording = true;
    notifyListeners();

    showToast('Recording Started');
  }

  stopRecording()async{

    if(await _record.isRecording()){
      _audioFilePath = await _record.stop();
      showToast('Recording Stopped');
    }

    print('Audio file path: $_audioFilePath');

    _isRecording = false;

    sendAudioForPrediction();

    _afterRecordingFilePath = _audioFilePath ?? '';
    notifyListeners();
  }

  Future<void> sendAudioForPrediction() async {
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(_audioFilePath!, filename: 'recorded_audio.wav')
    });

    var dioInstance = Dio();
    var response = await dioInstance.post('http://127.0.0.1:8000/api/flutter-upload/', data: formData);

    // Handle prediction label from response.data
    if(response.statusCode == 200){
      print("Prediction : ${response.data['prediction']}");
    }else{
      print("Error: ${response.statusMessage}");
    }
  }
}