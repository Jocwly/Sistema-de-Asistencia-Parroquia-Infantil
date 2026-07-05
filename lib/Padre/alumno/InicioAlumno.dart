import 'package:flutter/material.dart';
import 'package:sapi/Login.dart';
import 'package:sapi/Padre/alumno/registrar_asistencia.dart';

class InicioAlumno extends StatelessWidget {
  const InicioAlumno({super.key});

  static get routeName => '/InicioAlumno';

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacementNamed(context, Login.routeName);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
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
                  const Text(
                    'Bienvenid@',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      // Solo ícono, sin acción por ahora
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Hola, Nombre del Alumno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gestión de Asistencia',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // ----- Cuadrícula de opciones -----
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MenuCard(
                            icon: Icons.camera_alt_outlined,
                            label: 'Registrar Asistencia',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RegistrarAsistencia.routeName,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuCard(
                            icon: Icons.calendar_today_outlined,
                            label: 'Calendario de Asistencias',
                            onTap: () {
                              // TODO: pon aquí tu ruta a Grupos
                              // Navigator.pushNamed(context, '/grupos');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MenuCard(
                            icon: Icons.history_outlined,
                            label: 'Historial de Asistencias',
                            onTap: () {
                              // TODO: pon aquí tu ruta a Asistencias
                              // Navigator.pushNamed(context, '/asistencias');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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

/// Tarjeta reutilizable de menú (compartida entre paneles)
class MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
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
