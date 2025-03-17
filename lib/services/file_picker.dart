import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilePickerService {
  Future<List<File>> pickMultipleFiles() async {
    FilePickerResult? results = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (results != null) {
      return results.files.map((file) => File(file.path!)).toList();
    }
    return [];
  }

  Future<String?> pickDirectory() async {
    final shared = await SharedPreferences.getInstance();
    final saveDirectory = shared.getString('saveDirectory');
    String? selectedDirectory;
    if (saveDirectory == null) {
      selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Choose where to save files",
      );
      if (selectedDirectory == null) {
        final downloadDirectory = await getDownloadsDirectory();
        selectedDirectory = downloadDirectory!.path;
        return selectedDirectory;
      }
      shared.setString('saveDirectory', selectedDirectory);
    }
    return selectedDirectory;
  }
}
