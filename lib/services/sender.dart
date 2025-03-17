import 'dart:io';

class SenderService {
  final String reciverIP;
  final int port;

  SenderService({required this.reciverIP, required this.port});

  Future<void> sendFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      print("File not exists");
      return;
    }

    try {
      final socket = await Socket.connect(reciverIP, port);
      print('connected to server');

      // Read file data
      final fileData = await file.readAsBytes();
      final fileName = file.uri.pathSegments.last;

      // header
      final header = '$fileName:${fileData.length}\n';
      socket.write(header);
      await socket.flush();

      const int chunkSize = 10 * 1024 * 1024;
      int offset = 0;

      while (offset < fileData.length) {
        int end =
            (offset + chunkSize < fileData.length)
                ? offset + chunkSize
                : fileData.length;
        socket.add(fileData.sublist(offset, end));
        offset = end;
        await socket.flush();
      }

      print("File sent successfully: $fileName (${fileData.length} bytes)");
      await socket.close();
    } catch (e) {
      print("Error sending file: $e");
    }
  }
}
