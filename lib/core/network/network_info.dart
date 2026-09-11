import 'dart:io';

/// Interface for inspecting network availability.
abstract class INetworkInfo {
  Future<bool> get isConnected;
}

/// Production network reachability checker using DNS lookup.
class NetworkInfo implements INetworkInfo {
  const NetworkInfo();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
