import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapi/services/grupos_service.dart';
import 'package:sapi/styles/InfoGrupostyles.dart';
import 'package:sapi/Administrador/InfoGrupo.dart';

class GestionGrupos extends StatefulWidget {
  const GestionGrupos({super.key});

  static const routeName = '/GestionGrupos';

  @override
  State<GestionGrupos> createState() => _GestionGruposState();
}

class _GestionGruposState extends State<GestionGrupos> {
  final GruposService gruposService = GruposService();

  String? nivelSeleccionado;

  final List<String> gruposPrimaria = const [
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

  final List<String> gruposSecundaria = const ['1A', '1B'];

  List<String> get gruposDelNivel {
    if (nivelSeleccionado == 'PRIMARIA') {
      return gruposPrimaria;
    }

    if (nivelSeleccionado == 'SECUNDARIA') {
      return gruposSecundaria;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GruposStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: DropdownButtonFormField<String>(
                value: nivelSeleccionado,
                decoration: InputDecoration(
                  labelText: 'NIVEL',
                  hintText: 'Selecciona un nivel',
                  prefixIcon: const Icon(
                    Icons.school_rounded,
                    color: GruposStyles.primaryYellow,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: GruposStyles.primaryYellow,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: GruposStyles.primaryYellow,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: GruposStyles.primaryYellow,
                      width: 2,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'PRIMARIA', child: Text('PRIMARIA')),
                  DropdownMenuItem(
                    value: 'SECUNDARIA',
                    child: Text('SECUNDARIA'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    nivelSeleccionado = value;
                  });
                },
              ),
            ),

            Expanded(
              child: nivelSeleccionado == null
                  ? const _SeleccionaNivel()
                  : _construirListaGrupos(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirListaGrupos() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: gruposService.obtenerGrupos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: GruposStyles.primaryYellow),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Ocurrió un error al cargar los grupos'),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        return ListView.separated(
          padding: GruposStyles.screenPadding,
          itemCount: gruposDelNivel.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final grupo = gruposDelNivel[index];

            for (final documento in documentos) {
              final data = documento.data();
              final grupoFirebase = (data['grupo'] ?? '')
                  .toString()
                  .trim()
                  .toUpperCase();
            }

            return _GrupoCard(
              grupo: grupo,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InfoGrupo(grupo: grupo)),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SeleccionaNivel extends StatelessWidget {
  const _SeleccionaNivel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 75,
              color: GruposStyles.primaryYellow,
            ),
            const SizedBox(height: 16),
            Text('Selecciona un nivel', style: GruposStyles.cardTitle),
            const SizedBox(height: 8),
            const Text(
              'Selecciona PRIMARIA o SECUNDARIA para visualizar sus grupos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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

          // Este espacio mantiene el título centrado.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _GrupoCard extends StatelessWidget {
  final String grupo;
  final VoidCallback onTap;

  const _GrupoCard({required this.grupo, required this.onTap});

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
