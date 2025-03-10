import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecurityProvider with ChangeNotifier {
  final String _apiKey = dotenv.env['DEPSEK_API_KEY'] ?? '';
  Map<String, dynamic>? _currentDestinationData;
  List<Map<String, dynamic>> _registeredDevices = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentDestinationData => _currentDestinationData;
  List<Map<String, dynamic>> get registeredDevices => _registeredDevices;

  Future<void> checkDestinationSecurity(String destination) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('https://api.depsek.com/v1/security/destination/$destination'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _currentDestinationData = json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos de seguridad');
      }
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void registerDevice(Map<String, dynamic> device) {
    _registeredDevices.add(device);
    notifyListeners();
  }

  void removeDevice(int index) {
    _registeredDevices.removeAt(index);
    notifyListeners();
  }

  List<String> getSecurityRecommendations(String destination) {
    // Recomendaciones basadas en el destino
    return [
      'Evite usar redes Wi-Fi públicas sin VPN',
      'Mantenga su software actualizado',
      'Active la autenticación de dos factores',
      'Realice copias de seguridad antes del viaje',
      'Use contraseñas únicas y fuertes',
    ];
  }
} 