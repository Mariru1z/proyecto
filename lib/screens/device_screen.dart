import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceTypeController = TextEditingController();

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceTypeController.dispose();
    super.dispose();
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nuevo Dispositivo'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _deviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del dispositivo',
                  hintText: 'Ej: Mi iPhone 13',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de dispositivo',
                  hintText: 'Ej: Smartphone, Laptop, Tablet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un tipo';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final provider = context.read<SecurityProvider>();
                provider.registerDevice({
                  'name': _deviceNameController.text,
                  'type': _deviceTypeController.text,
                  'dateAdded': DateTime.now().toIso8601String(),
                });
                Navigator.pop(context);
                _deviceNameController.clear();
                _deviceTypeController.clear();
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SecurityProvider>(
        builder: (context, provider, child) {
          final devices = provider.registeredDevices;
          
          return devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.devices,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay dispositivos registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddDeviceDialog,
                        child: const Text('Registrar Dispositivo'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: devices.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          device['type'].toString().toLowerCase() == 'smartphone'
                              ? Icons.smartphone
                              : device['type'].toString().toLowerCase() == 'laptop'
                                  ? Icons.laptop
                                  : Icons.tablet,
                        ),
                        title: Text(device['name']),
                        subtitle: Text(device['type']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.removeDevice(index),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 