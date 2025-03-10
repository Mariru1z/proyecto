import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _addSecurityZones();
  }

  void _addSecurityZones() {
    // Ejemplo de zonas de seguridad (esto se actualizaría con datos reales de la API)
    final securityZones = [
      {
        'location': const LatLng(48.8566, 2.3522), // París
        'risk': 'medium',
        'name': 'París',
      },
      {
        'location': const LatLng(40.7128, -74.0060), // Nueva York
        'risk': 'high',
        'name': 'Nueva York',
      },
      {
        'location': const LatLng(-33.8688, 151.2093), // Sydney
        'risk': 'low',
        'name': 'Sydney',
      },
    ];

    for (var zone in securityZones) {
      final Color color = zone['risk'] == 'high'
          ? Colors.red.withOpacity(0.3)
          : zone['risk'] == 'medium'
              ? Colors.yellow.withOpacity(0.3)
              : Colors.green.withOpacity(0.3);

      _circles.add(
        Circle(
          circleId: CircleId(zone['name'] as String),
          center: zone['location'] as LatLng,
          radius: 50000, // 50km
          fillColor: color,
          strokeColor: color.withOpacity(0.8),
          strokeWidth: 2,
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId(zone['name'] as String),
          position: zone['location'] as LatLng,
          infoWindow: InfoWindow(
            title: zone['name'] as String,
            snippet: 'Nivel de riesgo: ${zone['risk']}',
          ),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialPosition,
        markers: _markers,
        circles: _circles,
        mapType: MapType.normal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
} 