import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapi/services/grupos_service.dart';
import 'package:sapi/styles/InfoGrupostyles.dart';
import 'package:sapi/Administrador/InfoGrupo.dart';

class GestionGrupos extends StatelessWidget {
  const GestionGrupos({super.key});

  static const routeName = '/GestionGrupos';

  @override
  Widget build(BuildContext context) {
    final gruposService = GruposService();

    return Scaffold(
      backgroundColor: GruposStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onAdd: () => _mostrarFormularioAgregarGrupo(context)),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: gruposService.obtenerGrupos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay grupos registrados'),
                    );
                  }

                  final grupos = snapshot.data!.docs;

                  return ListView.separated(
                    padding: GruposStyles.screenPadding,
                    itemCount: grupos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = grupos[index].data();
                      final grupo = data['grupo'] ?? '';
                      final catequista = data['catequista'] ?? '';

                      return _GrupoCard(
                        grupo: grupo,
                        catequista: catequista,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InfoGrupo(
                                grupo: grupo,
                                catequista: catequista,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioAgregarGrupo(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final catequistaController = TextEditingController();
    final otroGrupoController = TextEditingController();

    String grupoSeleccionado = 'A';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Agregar grupo',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: grupoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Grupo',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('A')),
                          DropdownMenuItem(value: 'B', child: Text('B')),
                          DropdownMenuItem(value: 'C', child: Text('C')),
                          DropdownMenuItem(value: 'D', child: Text('D')),
                          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            grupoSeleccionado = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      if (grupoSeleccionado == 'Otro')
                        TextFormField(
                          controller: otroGrupoController,
                          decoration: const InputDecoration(
                            labelText: 'Especificar grupo',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (grupoSeleccionado == 'Otro' &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Especifica el grupo';
                            }
                            return null;
                          },
                        ),

                      if (grupoSeleccionado == 'Otro')
                        const SizedBox(height: 12),

                      TextFormField(
                        controller: catequistaController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de catequista encargada',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre de la catequista';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GruposStyles.primaryYellow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final grupoFinal = grupoSeleccionado == 'Otro'
                        ? otroGrupoController.text.trim()
                        : grupoSeleccionado;

                    await GruposService().agregarGrupo(
                      grupo: grupoFinal,
                      catequista: catequistaController.text.trim(),
                    );

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;

  const _Header({required this.onAdd});

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
            child: Center(child: Text('Grupos', style: GruposStyles.title)),
          ),
          IconButton(icon: const Icon(Icons.add, size: 34), onPressed: onAdd),
        ],
      ),
    );
  }
}

class _GrupoCard extends StatelessWidget {
  final String grupo;
  final String catequista;

  final VoidCallback onTap;

  const _GrupoCard({
    required this.grupo,
    required this.catequista,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gruposService = GruposService();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: GruposStyles.cardDecoration,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: gruposService.obtenerAlumnosPorGrupo(grupo),
          builder: (context, snapshot) {
            final totalAlumnos = snapshot.data?.docs.length ?? 0;

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: GruposStyles.iconCircle,
                      child: const Icon(
                        Icons.groups_rounded,
                        color: GruposStyles.primaryYellow,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grupo $grupo', style: GruposStyles.cardTitle),
                          Text(catequista, style: GruposStyles.normal),
                        ],
                      ),
                    ),

                    Container(
                      width: 34,
                      height: 34,
                      decoration: GruposStyles.iconCircle,
                      child: const Icon(
                        Icons.chevron_right,
                        color: GruposStyles.primaryYellow,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 22),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: GruposStyles.softYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalAlumnos alumnos',
                      style: GruposStyles.boldSmall,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
