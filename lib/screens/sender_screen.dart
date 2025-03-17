// ignore_for_file: unused_element

import 'dart:io';

import 'package:air_share/models/filter.dart';
import 'package:air_share/services/file_picker.dart';
import 'package:air_share/services/network_utils.dart';
import 'package:air_share/services/sender.dart';
import 'package:flutter/material.dart';

class SenderScreen extends StatefulWidget {
  const SenderScreen({super.key});

  @override
  State<SenderScreen> createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final TextEditingController iPTextEditingController = TextEditingController();
  final int port = 3000;

  List<File> files = [];
  final List<Filter> _filters = [
    Filter(name: 'File', icon: Icon(Icons.file_open_rounded)),
    Filter(name: 'Media', icon: Icon(Icons.perm_media)),
    Filter(name: 'PDF', icon: Icon(Icons.picture_as_pdf)),
    Filter(name: 'Apps', icon: Icon(Icons.grid_view_rounded)),
  ];

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return "${kb.toStringAsFixed(2)} KB";
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return "${mb.toStringAsFixed(2)} MB";
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return "${gb.toStringAsFixed(2)} GB";
    }
  }

  Future<int> _calculateTotalSize() async {
    int totalSize = 0;
    for (var file in files) {
      totalSize += await file.length();
    }
    return totalSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Data"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select files type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // sending files with filters
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              width: double.infinity,
              child: ListView.builder(
                itemCount: _filters.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        final result =
                            await FilePickerService().pickMultipleFiles();
                        setState(() {
                          files.clear();
                          files.addAll(result);
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            filter.icon,
                            SizedBox(height: 4),
                            Text(
                              filter.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Review selected files
            Text(
              "Selected files",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            if (files.isNotEmpty) _buildPreviewWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: EdgeInsets.all(4),
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Text("Files to share"),
            Text(files.length.toString()),
            // FutureBuilder<int>(
            //   future: _calculateTotalSize(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Text("Calculating total size...");
            //     } else if (snapshot.hasError) {
            //       return Text("Error calculating total size");
            //     } else {
            //       String totalSize = _formatFileSize(snapshot.data!);
            //       return Text("Total size: $totalSize");
            //     }
            //   },
            // ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4,
                    ),
                    child: Column(children: [Icon(Icons.insert_drive_file)]),
                  );
                },
              ),
            ),
            SizedBox(
              height: 50,
              width: 100,
              child: TextField(
                controller: iPTextEditingController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String? ip = await NetworkUtils.getLocalIpAddress();
                    if (ip != null) {
                      _sendData(files, ip);
                    }
                  },
                  child: Text("Send"),
                ),
                ElevatedButton(onPressed: () {}, child: Text("Edit")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendData(List<File> filePath, String ipAddress) async {
    if (files.isEmpty) {
      print('No files selected');
      return;
    }
    print("check");
    for (File file in files) {
      SenderService sender = SenderService(
        reciverIP: iPTextEditingController.text.trim(),
        port: port,
      );
      await sender.sendFile(file.path);
    }
  }
}
