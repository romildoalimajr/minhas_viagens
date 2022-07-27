import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marcadores = {};

  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.562436, -46.655005), zoom: 18);


  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  FirebaseFirestore _db = FirebaseFirestore.instance;

  _adicionarMarcador(LatLng latLng) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print("local clicado: " + latLng.toString());

    List<Placemark> listaEnderecos =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (listaEnderecos.length > 0) {
      Placemark endereco = listaEnderecos[0];
      String? rua = endereco.thoroughfare;

      Marker marcador = Marker(
          markerId: MarkerId("marcador=${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: rua));
      print("rua " + rua.toString());
      setState(() {
        _marcadores.add(marcador);

        //salvar no firebase
        Map<String, dynamic> viagem = Map();
        viagem["titulo"] = rua;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;

        _db.collection("viagens").add(viagem);
      });
    }
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  _adicionarListenerLocalizacao() {
    void _getCurrentLocation() async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18);
        _movimentarCamera();
      });
    }
  }

  _recuperaViagemParaId(String idViagem) async {
    if (idViagem != null) {
      //exibir marcado para id viagem
      DocumentSnapshot documentSnapshot =
          await _db.collection("viagens").doc(idViagem).get();
      Map<String, dynamic> dados =
          documentSnapshot.data()! as Map<String, dynamic>;
      String titulo = dados["titulo"];
      LatLng latLng = LatLng(dados["latitude"], dados["longitude"]);

      setState(() {
        Marker marcador = Marker(
            markerId:
                MarkerId("marcador=${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(title: titulo));
        _marcadores.add(marcador);
        _posicaoCamera = CameraPosition(target: latLng, zoom: 18);
        _movimentarCamera();
      });
    } else {
      _adicionarListenerLocalizacao();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaViagemParaId(idViagem);
    //_adicionarListenerLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
      ),
      body: Container(
        child: GoogleMap(
          markers: _marcadores,
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
