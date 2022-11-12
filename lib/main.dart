import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_with_bottom_sheet/bloc/main_bloc.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'models/place.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google map example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PanelController _controller = PanelController();
  final Completer<GoogleMapController> _mapController = Completer();
  late LatLng currentLocation;
  Timer? _debounce;
  GoogleMapController? mapController;
  late ClusterManager _manager;

  @override
  void initState() {
    init();
    _manager = _initClusterManager();
    super.initState();
  }

  void init() async {
    mapController = await _mapController.future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SlidingUpPanelExample"),
        ),
        body: BlocProvider(
          lazy: true,
          create: (BuildContext context) => MainBloc(),
          child: BlocConsumer<MainBloc, MainState>(builder: (context, state) {
            return SlidingUpPanel(
              color: Colors.transparent,
              parallaxEnabled: true,
              backdropEnabled: false,
              maxHeight: 200,
              defaultPanelState: PanelState.OPEN,
              boxShadow: null,
              isDraggable: state.status != Status.loading,
              controller: _controller,
              collapsed: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: state.status == Status.loading
                    ? const CircularProgressIndicator()
                    : const Text("Collapsed"),
              ),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              panel: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(bottom: 24),
                alignment: Alignment.bottomCenter,
                child: CarouselSlider(
                  items: context
                      .read<MainBloc>()
                      .fakeAddressed
                      .map(
                        (e) => GestureDetector(
                          child: Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                e.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, color: Colors.black),
                              )),
                          onTap: () {
                            //
                          },
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      var address = context.read<MainBloc>().fakeAddressed[index];
                      mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: LatLng(double.parse(address.lat), double.parse(address.lon)),
                              zoom: 10),
                        ),
                      );
                    },
                    autoPlayInterval: const Duration(seconds: 2),
                    enlargeCenterPage: true,
                    viewportFraction: 0.85,
                    aspectRatio: 2.5,
                    initialPage: 0,
                  ),
                ),
              ),
              body: Stack(
                children: [
                  Align(
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _parisCameraPosition,
                        markers: markers,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController.complete(controller);
                          _manager.setMapId(controller.mapId);
                        },
                        onCameraMove: _manager.onCameraMove,
                        onCameraIdle: _manager.updateMap),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.my_location),
                  ),
                ],
              ),
            );
          }, listener: (context, state) {
            if (state.status == Status.loading) {
              _controller.close();
            }
            if (state.status == Status.success) {
              _controller.open();
            }
            if (state.status == Status.fail) {
              _controller.close();
            }
          }),
        ),
      ),
    );
  }

  Set<Marker> markers = {};

  final CameraPosition _parisCameraPosition =
      const CameraPosition(target: LatLng(48.856613, 2.352222), zoom: 12.0);

  List<Place> items = [
    for (int i = 0; i < 10; i++)
      Place(name: 'Place $i', latLng: LatLng(48.848200 + i * 0.001, 2.319124 + i * 0.001)),
    for (int i = 0; i < 10; i++)
      Place(name: 'Place $i', latLng: LatLng(48.848200 + (i * 100) * 0.001, 2.319124 + i * 0.001)),
  ];

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers, markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder => (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            for (var p in cluster.items) {
              print(p);
            }
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: size / 3, color: Colors.white, fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
}
