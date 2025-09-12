import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();

  LatLng? currentLocation;
  Marker? selectedMarker;
  String? selectedHospitalName;
  String? selectedHospitalAddress;
  String? selectedHospitalPhone;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(
      "AIzaSyDnTww9skax5GLDSlIQwBbZavDPXe7lXPg",
    ); // API key
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // ignore: deprecated_member_use
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation!, zoom: 15),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    if (value.isNotEmpty) {
      var result = await googlePlace.autocomplete.get(value, types: "hospital");
      if (result != null && result.predictions != null && mounted) {
        setState(() {
          predictions = result.predictions!;
        });
      }
    } else {
      setState(() {
        predictions = [];
      });
    }
  }

  void _onPredictionTap(AutocompletePrediction prediction) async {
    var details = await googlePlace.details.get(prediction.placeId!);
    if (details != null && details.result != null) {
      final location = details.result!.geometry!.location!;
      final latLng = LatLng(location.lat!, location.lng!);

      setState(() {
        selectedMarker = Marker(
          markerId: MarkerId(prediction.placeId!),
          position: latLng,
          infoWindow: InfoWindow(title: details.result!.name),
        );
        selectedHospitalName = details.result!.name;
        selectedHospitalAddress = details.result!.formattedAddress ?? '';
        selectedHospitalPhone = details.result!.formattedPhoneNumber;
        predictions = [];
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    }
  }

  Future<void> _launchDirections() async {
    if (selectedMarker == null) return;
    final lat = selectedMarker!.position.latitude;
    final lng = selectedMarker!.position.longitude;
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // 🔍 Search bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: searchController,
            onChanged: autoCompleteSearch,
            decoration: InputDecoration(
              hintText: "Search for hospitals...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() => predictions = []);
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),

        // 🔽 Predictions list or map
        if (predictions.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.red),
                  title: Text(predictions[index].description ?? ""),
                  onTap: () => _onPredictionTap(predictions[index]),
                );
              },
            ),
          )
        else
          Expanded(
            child: Stack(
              children: [
                // 🗺️ Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation ?? const LatLng(0, 0),
                    zoom: currentLocation == null ? 2 : 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: selectedMarker != null ? {selectedMarker!} : {},
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),

                // 🏥 Info card
                if (selectedHospitalName != null)
                  Positioned(
                    bottom: 30,
                    left: 15,
                    right: 15,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Hospital name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedHospitalName!,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      selectedHospitalName = null;
                                      selectedHospitalAddress = null;
                                      selectedHospitalPhone = null;
                                      selectedMarker = null;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            //Hospital Address
                            if (selectedHospitalAddress != null && selectedHospitalAddress!.isNotEmpty) ...[
                              Text(
                              selectedHospitalAddress ?? '',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10)
                            ],

                            //Hospital Contact
                            if (selectedHospitalPhone != null && selectedHospitalPhone!.isNotEmpty) ...[
                              Row(
                                children: [
                                  Text('Phone:'),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedHospitalPhone!,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.call, color: Colors.green),
                                    onPressed: () {
                                      final phoneUri = Uri(
                                        scheme: "tel",
                                        path: selectedHospitalPhone,
                                      );
                                      launchUrl(phoneUri);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],

                            //Directions
                            ElevatedButton.icon(
                              onPressed: _launchDirections,
                              icon: const Icon(Icons.directions),
                              label: const Text(
                                "Get Directions",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                backgroundColor: const Color(0xFF890000),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 📍 Current Location Button
                Positioned(
                  top: 20,
                  right: 15,
                  child: FloatingActionButton(
                    heroTag: "currentLocationBtn",
                    backgroundColor: Colors.blue,
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
