import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _grupoSeleccionado;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
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
            'grupo': _grupoSeleccionado,
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
        mensaje = 'La contraseña debe tener mínimo 8 caracteres';
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _correoValido(String correo) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(correo);
  }

  bool _nombreValido(String nombre) {
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    return regex.hasMatch(nombre);
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"),
                      ),
                    ],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      prefixIcon: Icon(Icons.person),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ingresa tu nombre";
                      }

                      if (!_nombreValido(value.trim())) {
                        return "El nombre no debe contener números";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Edad",
                      prefixIcon: Icon(Icons.cake),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingresa tu edad";
                      }

                      if (value.length != 2) {
                        return "La edad debe tener 2 dígitos";
                      }

                      final edad = int.tryParse(value);

                      if (edad == null || edad <= 0) {
                        return "Edad inválida";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('grupos')
                        .orderBy('grupo')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text(
                          'No hay grupos disponibles. Pide al admin que agregue uno.',
                        );
                      }

                      final grupos = snapshot.data!.docs;

                      return DropdownButtonFormField<String>(
                        value: _grupoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: "Grupo",
                          prefixIcon: Icon(Icons.groups),
                          border: LoginStyles.inputBorder,
                        ),
                        items: grupos.map((doc) {
                          final data = doc.data();
                          final grupo = data['grupo']?.toString() ?? '';

                          return DropdownMenuItem<String>(
                            value: grupo,
                            child: Text('Grupo $grupo'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _grupoSeleccionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Selecciona un grupo";
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ingresa un correo";
                      }

                      if (!_correoValido(value.trim())) {
                        return "Correo inválido";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
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

                      if (value.length < 8) {
                        return "Mínimo 8 caracteres";
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
