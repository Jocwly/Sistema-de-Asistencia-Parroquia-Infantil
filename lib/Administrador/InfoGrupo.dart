import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapi/services/grupos_service.dart';
import 'package:sapi/styles/InfoGrupostyles.dart';

class InfoGrupo extends StatelessWidget {
  final String grupo;

  const InfoGrupo({super.key, required this.grupo});

  @override
  Widget build(BuildContext context) {
    final gruposService = GruposService();

    return Scaffold(
      backgroundColor: GruposStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderDetalle(titulo: 'Grupo $grupo'),

            Expanded(
              child: SingleChildScrollView(
                padding: GruposStyles.screenPadding,
                child: Column(
                  children: [
                    _InfoGrupoCard(grupo: grupo),

                    const SizedBox(height: 16),

                    _AlumnosCard(
                      stream: gruposService.obtenerAlumnosPorGrupo(grupo),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDetalle extends StatelessWidget {
  final String titulo;

  const _HeaderDetalle({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: GruposStyles.primaryYellow, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(child: Text(titulo, style: GruposStyles.title)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InfoGrupoCard extends StatelessWidget {
  final String grupo;

  const _InfoGrupoCard({required this.grupo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GruposStyles.cardDecoration,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: GruposService().obtenerAlumnosPorGrupo(grupo),
        builder: (context, snapshot) {
          final totalAlumnos = snapshot.data?.docs.length ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información del Grupo', style: GruposStyles.cardTitle),
              const SizedBox(height: 18),

              _InfoRow(
                label: 'Alumnos inscritos',
                value: totalAlumnos.toString(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GruposStyles.normal),
        const Spacer(),
        Text(value, style: GruposStyles.boldSmall),
      ],
    );
  }
}

class _AlumnosCard extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  const _AlumnosCard({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GruposStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alumnos del Grupo', style: GruposStyles.cardTitle),
          const SizedBox(height: 14),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text('Ocurrió un error al cargar los alumnos');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No hay alumnos en este grupo');
              }

              final alumnos = snapshot.data!.docs;

              return Column(
                children: alumnos.map((doc) {
                  final data = doc.data();

                  final nombre = data['nombre'] ?? 'Sin nombre';
                  final apellidos = data['apellidos'] ?? '';
                  final edad = data['edad']?.toString() ?? '-';

                  return _AlumnoItem(
                    idAlumno: doc.id,
                    nombre: '$nombre $apellidos'.trim(),
                    edad: edad,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AlumnoItem extends StatefulWidget {
  final String idAlumno;
  final String nombre;
  final String edad;

  const _AlumnoItem({
    required this.idAlumno,
    required this.nombre,
    required this.edad,
  });

  @override
  State<_AlumnoItem> createState() => _AlumnoItemState();
}

class _AlumnoItemState extends State<_AlumnoItem> {
  Timer? _temporizadorPresionado;
  bool _dialogoAbierto = false;

  void _iniciarPresionado() {
    _cancelarPresionado();

    _temporizadorPresionado = Timer(const Duration(seconds: 2), () {
      if (mounted && !_dialogoAbierto) {
        _mostrarConfirmacionEliminar();
      }
    });
  }

  void _cancelarPresionado() {
    _temporizadorPresionado?.cancel();
    _temporizadorPresionado = null;
  }

  Future<void> _mostrarConfirmacionEliminar() async {
    _dialogoAbierto = true;

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alumno'),
          content: Text('¿Deseas eliminar a ${widget.nombre}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    _dialogoAbierto = false;

    if (confirmar == true) {
      await _eliminarAlumno();
    }
  }

  Future<void> _eliminarAlumno() async {
    try {
      await GruposService().eliminarAlumno(widget.idAlumno);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.nombre} fue eliminado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar al alumno'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cancelarPresionado();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = widget.nombre
        .trim()
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .map((parte) => parte[0])
        .join()
        .toUpperCase();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // Comienza a contar los dos segundos.
      onTapDown: (_) {
        _iniciarPresionado();
      },

      // Si levanta el dedo antes, se cancela.
      onTapUp: (_) {
        _cancelarPresionado();
      },

      // También se cancela si mueve el dedo o hace scroll.
      onTapCancel: () {
        _cancelarPresionado();
      },

      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: GruposStyles.primaryYellow,
              child: Text(
                iniciales,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.nombre, style: GruposStyles.studentName),
                Text('${widget.edad} años', style: GruposStyles.studentAge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
