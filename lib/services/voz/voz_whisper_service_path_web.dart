import 'package:http/http.dart' as http;

String getTempAudioPath() => '';

Future<void> adjuntarAudio(http.MultipartRequest request, String path) async {
  final response = await http.get(Uri.parse(path));
  request.files.add(http.MultipartFile.fromBytes(
    'audio',
    response.bodyBytes,
    filename: 'audio.webm',
  ));
}
