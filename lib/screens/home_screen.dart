import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import 'map_screen.dart';
import 'device_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _destinationController = TextEditingController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad en Viajes'),
        elevation: 2,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMainContent(),
          const MapScreen(),
          const DeviceScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Dispositivos',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<SecurityProvider>(
      builder: (context, securityProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Ingrese su destino',
                  hintText: 'Ej: París, Francia',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      if (_destinationController.text.isNotEmpty) {
                        try {
                          await securityProvider.checkDestinationSecurity(
                            _destinationController.text,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (securityProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (securityProvider.currentDestinationData != null)
                _buildSecurityInfo(securityProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityInfo(SecurityProvider provider) {
    final recommendations = provider.getSecurityRecommendations(
      _destinationController.text,
    );

    return Expanded(
      child: ListView(
        children: [
          const Text(
            'Recomendaciones de Seguridad:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...recommendations.map((rec) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.security),
                  title: Text(rec),
                ),
              )),
        ],
      ),
    );
  }
} 