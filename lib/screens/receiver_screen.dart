import 'package:air_share/services/file_picker.dart';
import 'package:air_share/services/network_utils.dart';
import 'package:air_share/services/receiver.dart';
import 'package:flutter/material.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  late ReceiverService receiverService;

  @override
  void initState() {
    super.initState();
    _initializeReceiver();
  }

  Future<void> _initializeReceiver() async {
    String? ip = await NetworkUtils.getLocalIpAddress();
    if (ip != null) {
      setState(() {
        receiverService = ReceiverService(port: 3000, iP: ip);
        receiverService.startServer();
      });
    } else {
      print("Could not determine local IP address.");
    }
  }

  @override
  void dispose() {
    receiverService.stopServer();
    super.dispose();
  }

  String path = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Receive Data"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // status Text from stream
            Text(
              "Waiting...",
            ), // when i have the data it changes to a progress bar and when it's done it changes to a text with the a msg
            // device code to add it in the sender device
            Text("123"),
            // saving Path
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    controller: TextEditingController(text: path),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Saving Path",
                      hintText: "No Path Selected",
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final savePath =
                              await FilePickerService().pickDirectory();
                          if (savePath != null) {
                            setState(() {
                              path = savePath;
                            });
                          }
                        },
                        icon: Icon(Icons.folder_open_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
