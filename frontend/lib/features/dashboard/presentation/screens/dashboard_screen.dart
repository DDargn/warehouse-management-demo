import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/kpi_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (isWide) const _Sidebar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard de almacén',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Frontend Flutter Web preparado para conectarse a ${AppConfig.apiBaseUrl}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      const Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          KpiCard(
                            title: 'Productos',
                            value: '8',
                            description: 'Datos demo iniciales',
                            icon: Icons.inventory_2_outlined,
                          ),
                          KpiCard(
                            title: 'Stock bajo',
                            value: '2',
                            description: 'Pendientes de reposición',
                            icon: Icons.warning_amber_outlined,
                          ),
                          KpiCard(
                            title: 'Movimientos',
                            value: '12',
                            description: 'Entradas y salidas',
                            icon: Icons.swap_vert,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estado del proyecto',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Paso 6 completado: la app Flutter Web ya está creada. '
                                'En el paso 7 conectaremos esta interfaz con la API FastAPI.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Productos'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.swap_vert),
          selectedIcon: Icon(Icons.swap_vert_circle),
          label: Text('Movimientos'),
        ),
      ],
    );
  }
}
