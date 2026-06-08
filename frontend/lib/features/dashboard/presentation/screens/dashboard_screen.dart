import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/warehouse_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WarehouseRepository _repository = WarehouseRepository();

  late Future<DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _repository.getDashboardData();
  }

  void _reloadDashboard() {
    setState(() {
      _dashboardFuture = _repository.getDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: 'Recargar datos',
            onPressed: _reloadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (isWide) const _Sidebar(),
              Expanded(
                child: FutureBuilder<DashboardData>(
                  future: _dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingState();
                    }

                    if (snapshot.hasError) {
                      return _ErrorState(
                        error: snapshot.error.toString(),
                        onRetry: _reloadDashboard,
                      );
                    }

                    final data = snapshot.data;

                    if (data == null) {
                      return _ErrorState(
                        error: 'No se recibieron datos del backend.',
                        onRetry: _reloadDashboard,
                      );
                    }

                    return _DashboardContent(data: data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
  });

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            'Datos cargados desde ${AppConfig.apiBaseUrl}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KpiCard(
                title: 'Productos',
                value: data.totalProducts.toString(),
                description: 'Productos activos',
                icon: Icons.inventory_2_outlined,
              ),
              KpiCard(
                title: 'Stock bajo',
                value: data.totalLowStockProducts.toString(),
                description: 'Pendientes de reposición',
                icon: Icons.warning_amber_outlined,
              ),
              KpiCard(
                title: 'Movimientos',
                value: data.totalMovements.toString(),
                description: 'Entradas y salidas',
                icon: Icons.swap_vert,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _ProductsTable(products: data.products),
        ],
      ),
    );
  }
}

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('SKU')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Stock mín.')),
                    DataColumn(label: Text('Ubicación')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Estado')),
                  ],
                  rows: products.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(Text(product.id.toString())),
                        DataCell(Text(product.name)),
                        DataCell(Text(product.sku)),
                        DataCell(Text(product.category)),
                        DataCell(Text(product.stock.toString())),
                        DataCell(Text(product.minStock.toString())),
                        DataCell(Text(product.location ?? '-')),
                        DataCell(Text('${product.unitPrice.toStringAsFixed(2)} €')),
                        DataCell(
                          product.isLowStock
                              ? const Chip(
                                  label: Text('Stock bajo'),
                                  avatar: Icon(Icons.warning_amber, size: 18),
                                )
                              : const Chip(
                                  label: Text('OK'),
                                  avatar: Icon(Icons.check_circle, size: 18),
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No se pudieron cargar los datos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
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
