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
  final _telefonoController = TextEditingController();
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
    _telefonoController.dispose();
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

    final correo = _correoController.text.trim();

    final telefono = _telefonoController.text.trim();

    if (correo.isEmpty && telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo o teléfono'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String correoAuth;

     
      if (correo.isNotEmpty) {
        correoAuth = correo;
      }
   
      else {
        correoAuth = '$telefono@sapi.com';
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: correoAuth,

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
            'nivel': _nivelSeleccionado,
            'grupo': _grupoSeleccionado,
            'correo': correo,
            'telefono': telefono,
            'correoAuth': correoAuth,

            'rol': 'alumno',

            'fechaRegistro': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alumno registrado en '
            '$_nivelSeleccionado - '
            'Grupo $_grupoSeleccionado',
          ),

          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrar usuario';

      if (e.code == 'email-already-in-use') {
        mensaje = 'El correo o teléfono ya está registrado';
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

  bool _telefonoValido(String telefono) {
    final regex = RegExp(r'^[0-9]{10}$');

    return regex.hasMatch(telefono);
  }

  bool _nombreValido(String nombre) {
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

    return regex.hasMatch(nombre);
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 48),
                  LoginStyles.logoIcon(),
                  const SizedBox(height: LoginStyles.titleSpacing),
                  Text(
                    'Registro de Alumno',
                    textAlign: TextAlign.center,
                    style: LoginStyles.titleStyle(context),
                  ),
                  const SizedBox(height: LoginStyles.sectionSpacing),
              
                  TextFormField(
                    controller: _nombreController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                      ),
                    ],

                    textCapitalization: TextCapitalization.words,

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

                  TextFormField(
                    controller: _edadController,

                    keyboardType: TextInputType.number,

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

                  _construirSelectorGrupo(),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  // CORREO
                  TextFormField(
                    controller: _correoController,

                    keyboardType: TextInputType.emailAddress,

                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico (opcional)',

                      prefixIcon: Icon(Icons.email_outlined),

                      border: LoginStyles.inputBorder,
                    ),

                    validator: (value) {
                      final correo = value?.trim() ?? '';

                      final telefono = _telefonoController.text.trim();

                      if (correo.isEmpty && telefono.isEmpty) {
                        return 'Ingresa correo o teléfono';
                      }

                      if (correo.isNotEmpty && !_correoValido(correo)) {
                        return 'Correo inválido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: LoginStyles.fieldSpacing),

                  TextFormField(
                    controller: _telefonoController,

                    keyboardType: TextInputType.phone,

                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,

                      LengthLimitingTextInputFormatter(10),
                    ],

                    decoration: const InputDecoration(
                      labelText: 'Teléfono (opcional)',

                      hintText: '10 dígitos',

                      prefixIcon: Icon(Icons.phone),

                      border: LoginStyles.inputBorder,
                    ),

                    validator: (value) {
                      final telefono = value?.trim() ?? '';

                      final correo = _correoController.text.trim();

                      if (telefono.isEmpty && correo.isEmpty) {
                        return 'Ingresa correo o teléfono';
                      }

                      if (telefono.isNotEmpty && !_telefonoValido(telefono)) {
                        return 'Teléfono inválido';
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
