import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:sapi/Login.dart';
import 'package:sapi/Administrador/InicioAdmin.dart';
import 'package:sapi/Padre/alumno/InicioAlumno.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      initialRoute: Login.routeName,
      routes: {
        Login.routeName: (_) => const Login(),
        InicioAdmin.routeName: (_) => const InicioAdmin(),
        InicioAlumno.routeName: (_) => const InicioAlumno(),
      },
    );
  }
}
