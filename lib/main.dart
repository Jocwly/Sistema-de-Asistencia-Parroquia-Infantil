import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sapi/Administrador/Calendario.dart';
import 'package:sapi/Administrador/ControlAsistencia.dart';
import 'package:sapi/Administrador/GestionGrupos.dart';
import 'package:sapi/Administrador/Reportes.dart';
import 'package:sapi/Padre/alumno/calendario.dart';
import 'package:sapi/Padre/alumno/historial.dart';
import 'package:sapi/Padre/alumno/registro.dart';
import 'firebase_options.dart';
import 'package:sapi/Login.dart';
import 'package:sapi/Administrador/InicioAdmin.dart';
import 'package:sapi/Padre/alumno/InicioAlumno.dart';
import 'package:sapi/Padre/alumno/registrar_asistencia.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      locale: const Locale('es', 'MX'),

      supportedLocales: const [Locale('es', 'MX'), Locale('es'), Locale('en')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      initialRoute: Login.routeName,
      routes: {
        Login.routeName: (_) => const Login(),
        InicioAdmin.routeName: (_) => const InicioAdmin(),
        InicioAlumno.routeName: (_) => const InicioAlumno(),
        Registro.routeName: (_) => const Registro(),
        RegistrarAsistencia.routeName: (_) => const RegistrarAsistencia(),
        GestionGrupos.routeName: (_) => const GestionGrupos(),
        Calendario.routeName: (_) => const Calendario(),
        MiHistorial.routeName: (_) => const MiHistorial(),
        CalendarioAdmin.routeName: (_) => const CalendarioAdmin(),
        ControlAsistencia.routeName: (_) => const ControlAsistencia(),
        GenerarReportes.routeName: (_) => const GenerarReportes(),
      },
    );
  }
}
