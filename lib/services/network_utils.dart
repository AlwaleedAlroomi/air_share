import 'dart:io';

class NetworkUtils {
  static Future<String?> getLocalIpAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address; // Returns the first valid local network IP
        }
      }
    }
    return null;
  }
}
