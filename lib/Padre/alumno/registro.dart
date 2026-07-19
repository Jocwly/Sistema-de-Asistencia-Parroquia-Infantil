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
  final _apellidosController = TextEditingController();
  final _edadController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nivelSeleccionado;
  String? _grupoSeleccionado;

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const List<String> _gruposPrimaria = [
    '2A',
    '2B',
    '3A',
    '3B',
    '4A',
    '4B',
    '5A',
    '5B',
    '6A',
    '6B',
  ];

  static const List<String> _gruposSecundaria = ['1A', '1B'];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _edadController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nivelSeleccionado == null || _grupoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un nivel y un grupo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
            'apellidos': _apellidosController.text.trim(),
            'edad': int.parse(_edadController.text.trim()),

            // Datos utilizados por Gestión de Grupos
            'nivel': _nivelSeleccionado,
            'grupo': _grupoSeleccionado,

            'correo': _correoController.text.trim(),
            'rol': 'alumno',
            'fechaRegistro': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alumno registrado en '
            '$_nivelSeleccionado - Grupo $_grupoSeleccionado',
          ),
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
          content: Text('Error al registrar: $e'),
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

  bool _correoValido(String correo) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

    return regex.hasMatch(correo);
  }

  bool _nombreValido(String nombre) {
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

    return regex.hasMatch(nombre);
  }

  List<String> _filtrarGruposExistentes(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documentos,
  ) {
    if (_nivelSeleccionado == null) {
      return [];
    }

    final gruposPermitidos = _nivelSeleccionado == 'PRIMARIA'
        ? _gruposPrimaria
        : _gruposSecundaria;

    final gruposExistentes = documentos
        .map((documento) {
          final data = documento.data();

          return (data['grupo'] ?? '').toString().trim().toUpperCase();
        })
        .where((grupo) {
          return grupo.isNotEmpty && gruposPermitidos.contains(grupo);
        })
        .toSet()
        .toList();

    gruposExistentes.sort();

    return gruposExistentes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      //appBar: AppBar(title: const Text('Registro'), centerTitle: true),
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
                    'Registro de Alumno',
                    textAlign: TextAlign.center,
                    style: LoginStyles.titleStyle(context),
                  ),

                  const SizedBox(height: LoginStyles.sectionSpacing),

                  // NOMBRE
                  TextFormField(
                    controller: _nombreController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                      ),
                    ],
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }

                      if (!_nombreValido(value.trim())) {
                        return 'El nombre no debe contener números';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _apellidosController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'),
                      ),
                    ],
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tus apellidos';
                      }

                      if (!_nombreValido(value.trim())) {
                        return 'Los apellidos no deben contener números';
                      }

                      if (value.trim().length < 3) {
                        return 'Ingresa apellidos válidos';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: LoginStyles.fieldSpacing),

                  // EDAD
                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      prefixIcon: Icon(Icons.cake),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu edad';
                      }

                      final edad = int.tryParse(value);

                      if (edad == null) {
                        return 'Edad inválida';
                      }

                      if (edad < 6) {
                        return 'La edad mínima es de 6 años';
                      }

                      if (edad > 99) {
                        return 'Edad inválida';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  // NIVEL
                  DropdownButtonFormField<String>(
                    value: _nivelSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Nivel',
                      prefixIcon: Icon(Icons.school_rounded),
                      border: LoginStyles.inputBorder,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PRIMARIA',
                        child: Text('PRIMARIA'),
                      ),
                      DropdownMenuItem(
                        value: 'SECUNDARIA',
                        child: Text('SECUNDARIA'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _nivelSeleccionado = value;

                        // Reinicia el grupo cuando cambia el nivel
                        _grupoSeleccionado = null;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un nivel';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  // GRUPO
                  _construirSelectorGrupo(),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  // CORREO
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: LoginStyles.inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa un correo';
                      }

                      if (!_correoValido(value.trim())) {
                        return 'Correo inválido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  // CONTRASEÑA
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
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
                        return 'Ingresa una contraseña';
                      }

                      if (value.length < 8) {
                        return 'Mínimo 8 caracteres';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  FilledButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: LoginStyles.loginButtonStyle(),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrarse',
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

  Widget _construirSelectorGrupo() {
    if (_nivelSeleccionado == null) {
      return DropdownButtonFormField<String>(
        value: null,
        decoration: const InputDecoration(
          labelText: 'Grupo',
          hintText: 'Primero selecciona un nivel',
          prefixIcon: Icon(Icons.groups),
          border: LoginStyles.inputBorder,
        ),
        items: const [],
        onChanged: null,
        validator: (_) {
          if (_nivelSeleccionado == null) {
            return 'Primero selecciona un nivel';
          }

          return null;
        },
      );
    }

    final gruposDisponibles = _nivelSeleccionado == 'PRIMARIA'
        ? _gruposPrimaria
        : _gruposSecundaria;

    return DropdownButtonFormField<String>(
      value: gruposDisponibles.contains(_grupoSeleccionado)
          ? _grupoSeleccionado
          : null,
      decoration: const InputDecoration(
        labelText: 'Grupo',
        hintText: 'Selecciona un grupo',
        prefixIcon: Icon(Icons.groups),
        border: LoginStyles.inputBorder,
      ),
      items: gruposDisponibles.map((grupo) {
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
          return 'Selecciona un grupo';
        }

        return null;
      },
    );
  }
}
