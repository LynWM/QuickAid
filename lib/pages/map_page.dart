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

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyDnTww9skax5GLDSlIQwBbZavDPXe7lXPg"); // Replace with your API key
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation!, zoom: 15),
    ));
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
    final url = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Google Map
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

        // Search bar
        Positioned(
          top: 40,
          left: 15,
          right: 15,
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: autoCompleteSearch,
                decoration: InputDecoration(
                  hintText: "Search hospitals...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              if (predictions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.local_hospital, color: Colors.red),
                        title: Text(predictions[index].description ?? ""),
                        onTap: () => _onPredictionTap(predictions[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Info card
        if (selectedHospitalName != null)
          Positioned(
            bottom: 30,
            left: 15,
            right: 15,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedHospitalName!,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(selectedHospitalAddress ?? '', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _launchDirections,
                      icon: const Icon(Icons.directions),
                      label: const Text("Get Directions"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
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

        // Current Location Button
        Positioned(
          bottom: 100,
          right: 15,
          child: FloatingActionButton(
            heroTag: "currentLocationBtn",
            backgroundColor: Colors.blue,
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
