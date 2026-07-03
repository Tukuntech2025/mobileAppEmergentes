import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceFormPage extends StatefulWidget {
  final String initialEmail;
  const DeviceFormPage({super.key, required this.initialEmail});

  @override
  State<DeviceFormPage> createState() => _DeviceFormPageState();
}

class _DeviceFormPageState extends State<DeviceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController(text: 'MiWiFi');
  final _wifiPasswordController = TextEditingController(text: '12345678');
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _connectionStatus = 'Desconectado';
  String _writeStatus = '';
  BluetoothCharacteristic? _configCharacteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _statusSubscription;

  static const Color _primary = Color(0xFF3B9784);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() {
          _adapterState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _stopScan();
    _disconnect();
    _adapterStateSubscription?.cancel();
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startScan() async {
    if (_isScanning) return;

    setState(() {
      _scanResults.clear();
      _isScanning = true;
      _connectionStatus = 'Escaneando dispositivos BLE...';
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        final filtered = results.where((r) {
          final name = r.advertisementData.advName;
          final pName = r.device.platformName;
          return name == "TukunTech Band" || pName == "TukunTech Band";
        }).toList();

        if (mounted) {
          setState(() {
            _scanResults = filtered;
          });
        }
      });
    } catch (e) {
      print("Error starting scan: $e");
      if (mounted) {
        setState(() {
          _isScanning = false;
          _connectionStatus = 'Error al iniciar escaneo';
        });
      }
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isScanning) {
        _stopScan();
        if (_scanResults.isEmpty) {
          setState(() {
            _connectionStatus = 'No se encontró TukunTech Band';
          });
        }
      }
    });
  }

  void _stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    _scanSubscription?.cancel();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _connect(BluetoothDevice device) async {
    _stopScan();

    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Conectando a ${device.remoteId.str}...';
    });

    try {
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnect();
        }
      });

      try {
        await device.requestMtu(512);
        if (mounted) {
          setState(() {
            _connectionStatus = 'MTU BLE negociado. Descubriendo servicios...';
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _connectionStatus = 'No se pudo negociar MTU. Descubriendo servicios...';
          });
        }
      }

      List<BluetoothService> services = await device.discoverServices();
      BluetoothService? targetService;
      for (var s in services) {
        if (s.uuid.toString().toLowerCase() == "12345678-1234-1234-1234-1234567890ab") {
          targetService = s;
          break;
        }
      }

      if (targetService == null) {
        if (mounted) {
          setState(() {
            _connectionStatus = 'Servicio TukunTech no encontrado';
            _isConnecting = false;
          });
        }
        device.disconnect();
        return;
      }

      BluetoothCharacteristic? configChar;
      BluetoothCharacteristic? statusChar;

      for (var c in targetService.characteristics) {
        if (c.uuid.toString().toLowerCase() == "abcd1234-5678-90ab-cdef-1234567890ab") {
          configChar = c;
        } else if (c.uuid.toString().toLowerCase() == "dcba4321-8765-09ba-fedc-0987654321ba") {
          statusChar = c;
        }
      }

      if (configChar == null) {
        if (mounted) {
          setState(() {
            _connectionStatus = 'Característica de configuración no encontrada';
            _isConnecting = false;
          });
        }
        device.disconnect();
        return;
      }

      _configCharacteristic = configChar;
      _connectedDevice = device;

      if (statusChar != null) {
        await _enableNotifications(statusChar);
      }

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
          _connectionStatus = 'Listo para enviar configuración WiFi';
        });
      }
    } catch (e) {
      print("Error connecting: $e");
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectionStatus = 'Error de conexión: $e';
        });
      }
      device.disconnect();
    }
  }

  Future<void> _enableNotifications(BluetoothCharacteristic characteristic) async {
    try {
      await characteristic.setNotifyValue(true);
      _statusSubscription = characteristic.lastValueStream.listen((value) {
        final statusStr = utf8.decode(value);
        if (mounted) {
          setState(() {
            _writeStatus = _mapDeviceStatus(statusStr);
          });
        }
      });
    } catch (e) {
      print("Error enabling notifications: $e");
    }
  }

  String _mapDeviceStatus(String status) {
    switch (status) {
      case "ready":
        return "Dispositivo listo para configurar";
      case "ble_connected":
        return "Celular conectado al dispositivo";
      case "wifi_connecting":
        return "Conectando al WiFi...";
      case "wifi_failed":
        return "No se pudo conectar al WiFi";
      case "authenticating":
        return "Verificando credenciales...";
      case "auth_success":
        return "Login del dispositivo exitoso";
      case "auth_failed":
        return "Credenciales inválidas o backend no disponible";
      case "auth_no_token":
        return "El dispositivo no recibió token del backend";
      case "provisioning_success":
        return "Dispositivo configurado correctamente";
      case "provisioning_wifi_failed":
        return "No se pudo configurar: falló el WiFi";
      case "provisioning_auth_failed":
        return "No se pudo configurar: falló el login";
      case "stored_login_success":
        return "Login guardado del dispositivo exitoso";
      case "stored_login_failed":
        return "Falló el login guardado del dispositivo";
      case "credentials_cleared":
        return "Configuración del dispositivo borrada";
      default:
        if (status.startsWith("wifi_connected:")) {
          final ip = status.replaceFirst("wifi_connected:", "");
          return "WiFi conectado. IP: $ip";
        }
        return "ESP32: $status";
    }
  }

  void _sendWifiConfig() async {
    if (_configCharacteristic == null) {
      setState(() {
        _writeStatus = 'No hay característica BLE lista para escribir';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _writeStatus = 'Enviando WiFi y credenciales al ESP32...';
    });

    try {
      final jsonPayload = jsonEncode({
        "wifi_ssid": _ssidController.text,
        "wifi_password": _wifiPasswordController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
      });

      final payloadBytes = utf8.encode(jsonPayload);
      await _configCharacteristic!.write(payloadBytes, withoutResponse: false);

      setState(() {
        _writeStatus = 'Configuración WiFi enviada correctamente';
      });
    } catch (e) {
      setState(() {
        _writeStatus = 'Error al escribir configuración BLE: $e';
      });
    }
  }

  void _clearDeviceConfig() async {
    if (_configCharacteristic == null) {
      setState(() {
        _writeStatus = 'No hay característica BLE lista para escribir';
      });
      return;
    }

    setState(() {
      _writeStatus = 'Solicitando borrado de configuración del dispositivo...';
    });

    try {
      final jsonPayload = jsonEncode({
        "action": "clear",
      });

      final payloadBytes = utf8.encode(jsonPayload);
      await _configCharacteristic!.write(payloadBytes, withoutResponse: false);
    } catch (e) {
      setState(() {
        _writeStatus = 'Error al borrar configuración BLE: $e';
      });
    }
  }

  void _disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
    }
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _statusSubscription?.cancel();
    _connectionSubscription?.cancel();
    if (mounted) {
      setState(() {
        _connectedDevice = null;
        _isConnected = false;
        _configCharacteristic = null;
        _connectionStatus = 'Desconectado';
        _writeStatus = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool bluetoothOn = _adapterState == BluetoothAdapterState.on;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configurar TukunTech Band',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: !bluetoothOn
            ? _buildBluetoothOffScreen()
            : !_isConnected
                ? _buildScanScreen()
                : _buildProvisioningScreen(),
      ),
    );
  }

  Widget _buildBluetoothOffScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bluetooth_disabled, size: 48, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bluetooth Apagado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Por favor, activa el Bluetooth en la configuración de tu teléfono para buscar y conectar tu TukunTech Band.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scan Title card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escaneo BLE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buscando dispositivo: TukunTech Band',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (_isScanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scan buttons row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isScanning || _isConnecting ? null : _startScan,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Escanear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !_isScanning ? null : _stopScan,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('Detener'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status & Progress indicator
          Text(
            _isScanning
                ? 'Escaneando...'
                : _isConnecting
                    ? 'Conectando...'
                    : 'Escaneo detenido',
            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            _connectionStatus,
            style: const TextStyle(fontSize: 13, color: _primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Discovered Devices list
          const Text(
            'Dispositivos encontrados:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _scanResults.isEmpty
                ? _buildEmptyScanResults()
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      final device = result.device;
                      final name = result.advertisementData.advName.isNotEmpty
                          ? result.advertisementData.advName
                          : device.platformName.isNotEmpty
                              ? device.platformName
                              : 'Sin nombre';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isConnecting ? null : () => _connect(device),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0F2F1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.memory, color: _primary, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        device.remoteId.str,
                                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Tocar para conectar',
                                        style: TextStyle(
                                          color: _primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.black26),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScanResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            _isScanning ? 'Buscando dispositivos...' : 'Presiona Escanear para buscar',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProvisioningScreen() {
    final bool canSend = _ssidController.text.isNotEmpty &&
        _wifiPasswordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connected device badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: _primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Conectado a ${_connectedDevice?.platformName ?? "TukunTech Band"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form inputs
            _buildTextField(
              label: 'WiFi SSID',
              controller: _ssidController,
              icon: Icons.wifi,
              hint: 'SSID de tu WiFi',
            ),
            const SizedBox(height: 14),

            _buildTextField(
              label: 'WiFi Password',
              controller: _wifiPasswordController,
              icon: Icons.lock_outline,
              hint: 'Contraseña de tu WiFi',
              obscure: true,
            ),
            const SizedBox(height: 14),

            _buildTextField(
              label: 'Email de login',
              controller: _emailController,
              icon: Icons.email_outlined,
              hint: 'Tu correo de TukunTech',
            ),
            const SizedBox(height: 14),

            _buildTextField(
              label: 'Password de login',
              controller: _passwordController,
              icon: Icons.vpn_key_outlined,
              hint: 'Tu contraseña de TukunTech',
              obscure: true,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            ElevatedButton(
              onPressed: canSend ? _sendWifiConfig : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Enviar configuración al ESP32',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: _clearDeviceConfig,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Borrar configuración del dispositivo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),

            // Status message
            if (_writeStatus.isNotEmpty) ...[
              const Text(
                'Estado del dispositivo:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _writeStatus,
                  style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Back & Disconnect buttons row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _disconnect();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Volver', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _disconnect,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Desconectar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          cursorColor: _primary,
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor llena este campo';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: _primary, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
