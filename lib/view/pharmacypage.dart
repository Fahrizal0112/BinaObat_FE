import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map_directions/flutter_map_directions.dart';
import 'dart:math' show cos, sqrt, asin;

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});
  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  LatLng? _currentPosition;
  List<Marker> _pharmacyMarkers = [];
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      await _getNearbyPharmacies();
    } catch (e) {
      print("Error mendapatkan lokasi: $e");
    }
  }

  Future<void> _getNearbyPharmacies() async {
    if (_currentPosition == null) return;

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    final query = '''
    [out:json];
    (
      node["amenity"="pharmacy"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
      way["amenity"="pharmacy"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
      relation["amenity"="pharmacy"](around:5000,${_currentPosition!.latitude},${_currentPosition!.longitude});
    );
    out center;
    ''';

    try {
      final response = await http.post(url, body: query);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pharmacyMarkers = (data['elements'] as List).map((element) {
            final lat = element['lat'] ?? element['center']['lat'];
            final lon = element['lon'] ?? element['center']['lon'];
            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(lat, lon),
              child: GestureDetector(
                onTap: () => _getRoute(LatLng(lat, lon)),
                child: Column(children: [
                  Text("Pharmacy", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                  Icon(Icons.local_pharmacy, color: Colors.green)
                ]),
              ),
            );
          }).toList();
        });
      }
    } catch (e) {
      print("Error mendapatkan data apotek: $e");
    }
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    final apiKey = '5b3ce3597851110001cf6248c5260ff37cd54007b3e3cd368fc8c3cb'; 
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiKey,
        },
        body: json.encode({
          'coordinates': [
            [_currentPosition!.longitude, _currentPosition!.latitude],
            [destination.longitude, destination.latitude],
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && 
            data['routes'] != null && 
            data['routes'].isNotEmpty &&
            data['routes'][0]['geometry'] != null) {
          final geometry = data['routes'][0]['geometry'];
          final decodedGeometry = decodePolyline(geometry);
          setState(() {
            _routePoints = decodedGeometry;
          });
        } else {
          print('Respons tidak memiliki struktur yang diharapkan: ${response.body}');
        }
      } else {
        print('Gagal mendapatkan rute. Status code: ${response.statusCode}');
        print('Respons body: ${response.body}');
      }
    } catch (e) {
      print('Error saat mendapatkan rute: $e');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;

      poly.add(LatLng(latitude, longitude));
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Pharmacy',
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                    ..._pharmacyMarkers,
                  ],
                ),
              ],
            ),
    );
  }
}