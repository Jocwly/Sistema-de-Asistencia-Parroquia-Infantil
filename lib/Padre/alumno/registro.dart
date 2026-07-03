import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapi/styles/form_styles.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  static const routeName = '/registro';

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _grupoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _grupoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _correoController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'nombre': _nombreController.text.trim(),
            'edad': int.parse(_edadController.text.trim()),
            'grupo': _grupoController.text.trim(),
            'correo': _correoController.text.trim(),
            'rol': 'alumno',
            'fechaRegistro': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro realizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrar usuario';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Correo inválido';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro"), centerTitle: true),
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
                    "Registro de Alumno",
                    textAlign: TextAlign.center,
                    style: LoginStyles.titleStyle(context),
                  ),

                  const SizedBox(height: LoginStyles.sectionSpacing),

                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      prefixIcon: Icon(Icons.person),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingresa tu nombre";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Edad",
                      prefixIcon: Icon(Icons.cake),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingresa tu edad";
                      }

                      final edad = int.tryParse(value);

                      if (edad == null || edad <= 0) {
                        return "Edad inválida";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _grupoController,
                    decoration: const InputDecoration(
                      labelText: "Grupo",
                      prefixIcon: Icon(Icons.groups),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingresa el grupo";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingresa un correo";
                      }

                      if (!value.contains("@")) {
                        return "Correo inválido";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock),
                      border: LoginStyles.inputBorder,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                        return "Ingresa una contraseña";
                      }

                      if (value.length < 6) {
                        return "Mínimo 6 caracteres";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  FilledButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: LoginStyles.loginButtonStyle(),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Registrarse",
                            style: LoginStyles.buttonText,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
