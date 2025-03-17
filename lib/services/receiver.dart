import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ReceiverService {
  final String iP;
  final int port;
  ServerSocket? _server;

  ReceiverService({required this.iP, required this.port});

  Future<void> startServer() async {
    try {
      _server = await ServerSocket.bind(iP, port);
      print('Server is listening on port $port');
      final sharedPath = await SharedPreferences.getInstance();
      _server!.listen((socket) {
        String fileName = '';
        int fileSize = 0;
        List<int> fileData = [];

        socket.listen(
          (data) async {
            try {
              if (fileName.isEmpty) {
                final headerend = data.indexOf(10);
                if (headerend != -1) {
                  String header =
                      utf8.decode(data.sublist(0, headerend)).trim();
                  List<String> fileParts = header.split(':');
                  if (fileParts.length < 2) {
                    print("Invalid header");
                    socket.close();
                    return;
                  }

                  fileName = fileParts[0];
                  fileSize = int.tryParse(fileParts[1]) ?? -1;
                  if (fileSize <= 0) {
                    print("Invalid file size");
                    socket.close();
                    return;
                  }

                  if (headerend + 1 < data.length) {
                    fileData.addAll(data.sublist(headerend + 1));
                  }
                }
              } else {
                fileData.addAll(data);
              }
              if (fileData.length >= fileSize) {
                final savePath =
                    '${sharedPath.getString('saveDirectory')}/$fileName';
                final file = File(savePath);
                await file.writeAsBytes(fileData);
                print(
                  "File successfully received: $fileName (${fileData.length} bytes) ${file.path}",
                );

                socket.close();
              }
            } catch (e) {
              print("❌ Error receiving file: $e");
            }
          },
          onDone: () {
            print("Connection closed.");
          },
          onError: (error) {
            print("Socket error: $error");
            socket.close();
          },
          cancelOnError: true,
        );
      });
    } catch (e) {
      print("❌ Failed to start server: $e");
    }
  }

  void stopServer() {
    if (_server != null) {
      _server!.close();
      print("🛑 Server stopped.");
      _server = null;
    } else {
      print("⚠️ Server is not running.");
    }
  }
}
