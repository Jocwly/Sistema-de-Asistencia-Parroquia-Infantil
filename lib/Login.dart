import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'styles/form_styles.dart';
import 'package:sapi/Administrador/InicioAdmin.dart';
import 'package:sapi/Padre/alumno/InicioAlumno.dart';
import 'package:sapi/Padre/alumno/registro.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _userController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  // OBTENER CORREO INTERNO CUANDO INGRESA TELÉFONO

  Future<String?> _obtenerCorreoAuth(String dato) async {
    // Si escribe correo usa ese directamente

    if (dato.contains('@')) {
      return dato;
    }

    // Si escribe teléfono buscamos en usuarios

    final resultado = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('telefono', isEqualTo: dato)
        .limit(1)
        .get();

    if (resultado.docs.isEmpty) {
      return null;
    }

    final usuario = resultado.docs.first.data();

    return usuario['correoAuth'];
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dato = _userController.text.trim();

      final correoAuth = await _obtenerCorreoAuth(dato);

      if (correoAuth == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correoAuth,

        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // ADMINISTRADOR

      if (credential.user?.email == 'admin@gmail.com') {
        Navigator.pushReplacementNamed(context, InicioAdmin.routeName);

        return;
      }

      final uid = credential.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se encontraron datos del usuario'),

            backgroundColor: LoginStyles.errorColor,
          ),
        );

        return;
      }

      final data = userDoc.data()!;

      final rol = data['rol'];

      if (rol == 'admin') {
        Navigator.pushReplacementNamed(context, InicioAdmin.routeName);
      } else if (rol == 'alumno') {
        Navigator.pushReplacementNamed(context, InicioAlumno.routeName);
      } else {
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rol de usuario no válido'),

            backgroundColor: LoginStyles.errorColor,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Usuario o contraseña incorrectos';

      if (e.code == 'user-not-found') {
        mensaje = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensaje = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Correo inválido';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),

          backgroundColor: LoginStyles.errorColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),

          backgroundColor: LoginStyles.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: LoginStyles.pagePadding,

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  LoginStyles.logoIcon(),

                  const SizedBox(height: LoginStyles.titleSpacing),

                  Text(
                    'Sistema de Asistencia Parroquia Infantil',

                    textAlign: TextAlign.center,

                    style: LoginStyles.titleStyle(context),
                  ),

                  const SizedBox(height: LoginStyles.titleSpacing),

                  const Text(
                    'Inicia Sesión',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 25,

                      fontWeight: FontWeight.bold,

                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextFormField(
                    controller: _userController,

                    keyboardType: TextInputType.text,

                    textInputAction: TextInputAction.next,

                    decoration: const InputDecoration(
                      labelText: 'Correo o teléfono',

                      prefixIcon: Icon(Icons.person_outline),

                      border: LoginStyles.inputBorder,
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa correo o teléfono';
                      }

                      final dato = value.trim();

                      if (!dato.contains('@')) {
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(dato)) {
                          return 'Teléfono inválido';
                        }
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _passwordController,

                    obscureText: _obscurePassword,

                    textInputAction: TextInputAction.done,

                    onFieldSubmitted: (_) => _onLogin(),

                    decoration: InputDecoration(
                      labelText: 'Contraseña',

                      prefixIcon: const Icon(Icons.lock_outlined),

                      border: LoginStyles.inputBorder,

                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),

                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }

                      if (value.length < 8) {
                        return 'Mínimo 8 caracteres';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _isLoading ? null : _onLogin,

                    style: LoginStyles.loginButtonStyle(),

                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Iniciar sesión',

                            style: LoginStyles.buttonText,
                          ),
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(fontSize: 15),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Registro.routeName);
                        },

                        child: const Text(
                          'Regístrate',

                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            color: Colors.black,

                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
