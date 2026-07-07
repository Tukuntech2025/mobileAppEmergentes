import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/localization/app_localizations.dart';

class AddressData {
  final String label;
  final TextEditingController controller;
  double? latitude;
  double? longitude;

  AddressData({
    required this.label,
    required this.controller,
    this.latitude,
    this.longitude,
  });
}

class StepAddress extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final List<AddressData> addresses;

  const StepAddress({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.addresses,
  });

  @override
  State<StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<StepAddress> {
  int _currentIndex = 0;
  final MapController _mapController = MapController();
  bool _isLoading = false;
  Timer? _debounce;

  // Default location (e.g., Lima, Peru as fallback, or anything central)
  final LatLng _defaultLocation = const LatLng(-12.0464, -77.0428);
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  AddressData get currentAddress => widget.addresses[_currentIndex];

  LatLng get _currentLatLng {
    if (currentAddress.latitude != null && currentAddress.longitude != null) {
      return LatLng(currentAddress.latitude!, currentAddress.longitude!);
    }
    return _defaultLocation;
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'TukunTechApp/1.0',
      });
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          setState(() {
            currentAddress.latitude = lat;
            currentAddress.longitude = lon;
          });
          
          _mapController.move(LatLng(lat, lon), 16.0);
        } else {
          _showSnackBar(context.translate('address_not_found') ?? 'Address not found');
        }
      }
    } catch (e) {
      debugPrint('Error searching address: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() {
      _isLoading = true;
      currentAddress.latitude = position.latitude;
      currentAddress.longitude = position.longitude;
    });
    
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json');
      final response = await http.get(url, headers: {
        'User-Agent': 'TukunTechApp/1.0',
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            currentAddress.controller.text = data['display_name'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error in reverse geocoding: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onAddressChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      _searchAddress(value);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B9784);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.addresses.length > 1) ...[
            Text(
              context.translate('select_patient_address') ?? 'Select patient to set address',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.addresses.length, (index) {
                  final isSelected = index == _currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(widget.addresses[index].label, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _currentIndex = index;
                            if (currentAddress.latitude != null && currentAddress.longitude != null) {
                               _mapController.move(LatLng(currentAddress.latitude!, currentAddress.longitude!), 16.0);
                            }
                          });
                        }
                      },
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                      padding: EdgeInsets.zero,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            context.translate('address'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: currentAddress.controller,
            onChanged: _onAddressChanged,
            onSubmitted: _searchAddress,
            decoration: InputDecoration(
              hintText: context.translate('enter_address'),
              hintStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: primaryColor),
                onPressed: () => _searchAddress(currentAddress.controller.text),
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E3DF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLatLng,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      _reverseGeocode(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tukuntech.app',
                    ),
                    if (currentAddress.latitude != null && currentAddress.longitude != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(currentAddress.latitude!, currentAddress.longitude!),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                if (_isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  ),
                  
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.add, size: 20, color: Colors.black87),
                          ),
                        ),
                        Container(height: 1, width: 28, color: Colors.grey.shade300),
                        InkWell(
                          onTap: () {
                            _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.remove, size: 20, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
                label: Text(
                  context.translate('back_btn'),
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    bool allValid = true;
                    for (var addr in widget.addresses) {
                      if (addr.controller.text.trim().isEmpty) {
                        allValid = false;
                        break;
                      }
                    }
                    if (!allValid) {
                      _showSnackBar(context.translate('error_fill_all_fields') ?? 'Please enter an address for all patients.');
                      return;
                    }
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B9784),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          context.translate('continue_btn'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
