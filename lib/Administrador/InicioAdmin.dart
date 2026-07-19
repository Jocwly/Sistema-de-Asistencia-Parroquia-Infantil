import 'package:flutter/material.dart';
import 'package:sapi/Administrador/Calendario.dart';
import 'package:sapi/Administrador/ControlAsistencia.dart';
import 'package:sapi/Administrador/GestionGrupos.dart';
import 'package:sapi/Administrador/Reportes.dart';

class InicioAdmin extends StatelessWidget {
  const InicioAdmin({super.key});

  static get routeName => '/InicioAdmin';

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- AppBar personalizada -----
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PopupMenuButton<String>(
                        icon: const CircleAvatar(
                          backgroundColor: Color(0xFF1F2A44),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        onSelected: (value) {
                          if (value == 'cerrar_sesion') {
                            _cerrarSesion(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'cerrar_sesion',
                            child: Text('Cerrar sesión'),
                          ),
                        ],
                      ),
                    ),

                    const Text(
                      'Panel Principal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ----- Saludo -----
              const Text(
                'Hola, Catequista',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gestiona la información y consulta la asistencia.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              //Cuadrícula de opciones
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        //GRUPOS
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.groups,
                            label: 'Grupos',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                GestionGrupos.routeName,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.fact_check,
                            label: 'Asistencias',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ControlAsistencia.routeName,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.description,
                            label: 'Reportes',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                GenerarReportes.routeName,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.calendar_today,
                            label: 'Calendario',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                CalendarioAdmin.routeName,
                              );
                            },
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
