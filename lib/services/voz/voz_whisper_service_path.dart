import 'dart:io';
import 'package:http/http.dart' as http;

String getTempAudioPath() {
  return '${Directory.systemTemp.path}/voz_movecare.m4a';
}

Future<void> adjuntarAudio(http.MultipartRequest request, String path) async {
  request.files.add(await http.MultipartFile.fromPath(
    'audio',
    path,
    filename: 'audio.m4a',
  ));
}
