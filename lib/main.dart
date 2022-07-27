import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

      runApp(MaterialApp(
        title: "Minhas Viagens",
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ));
}