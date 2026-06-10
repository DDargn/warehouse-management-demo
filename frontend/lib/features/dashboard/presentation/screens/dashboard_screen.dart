import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../data/models/stock_by_category_model.dart';
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

  void _openProductsScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const ProductsScreen(),
          ),
        )
        .then((_) => _reloadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          TextButton.icon(
            onPressed: _openProductsScreen,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Productos'),
          ),
          IconButton(
            tooltip: 'Recargar datos',
            onPressed: _reloadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.background,
              AppTheme.backgroundAlt,
              AppTheme.background,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return Row(
              children: [
                if (isWide)
                  _Sidebar(
                    selectedIndex: 0,
                    onProductsSelected: _openProductsScreen,
                  ),
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
    final summary = data.summary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroHeader(
            title: 'Dashboard de almacén',
            subtitle:
                'Monitoriza inventario, valor del stock, categorías y productos críticos en tiempo real.',
            trailing: _HeroBadge(
              label: 'API conectada',
              value: AppConfig.apiBaseUrl,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KpiCard(
                title: 'Productos activos',
                value: summary.totalProducts.toString(),
                description: 'Total de referencias',
                icon: Icons.inventory_2_outlined,
              ),
              KpiCard(
                title: 'Unidades en stock',
                value: summary.totalStockUnits.toString(),
                description: 'Suma del inventario',
                icon: Icons.warehouse_outlined,
              ),
              KpiCard(
                title: 'Valor del stock',
                value: '${summary.stockValue.toStringAsFixed(2)} €',
                description: 'Stock x precio unitario',
                icon: Icons.euro_outlined,
              ),
              KpiCard(
                title: 'Stock bajo',
                value: summary.lowStockProducts.toString(),
                description: 'Productos bajo mínimo',
                icon: Icons.warning_amber_outlined,
              ),
              KpiCard(
                title: 'Movimientos',
                value: summary.totalMovements.toString(),
                description: 'Entradas y salidas',
                icon: Icons.swap_vert,
              ),
              KpiCard(
                title: 'Categorías',
                value: summary.categoriesCount.toString(),
                description: 'Familias de producto',
                icon: Icons.category_outlined,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _StockByCategoryTable(items: data.stockByCategory),
          const SizedBox(height: 32),
          _LowStockTable(products: data.lowStockProducts),
          const SizedBox(height: 32),
          _ProductsTable(products: data.products),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102838),
            Color(0xFF0A1720),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_done_outlined,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockByCategoryTable extends StatelessWidget {
  const _StockByCategoryTable({
    required this.items,
  });

  final List<StockByCategoryModel> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Stock por categoría',
      subtitle: 'Agrupación del inventario por familia de producto.',
      icon: Icons.category_outlined,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Productos')),
            DataColumn(label: Text('Unidades')),
            DataColumn(label: Text('Valor')),
          ],
          rows: items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.category)),
                DataCell(Text(item.totalProducts.toString())),
                DataCell(Text(item.totalStockUnits.toString())),
                DataCell(Text('${item.stockValue.toStringAsFixed(2)} €')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LowStockTable extends StatelessWidget {
  const _LowStockTable({
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Productos con stock bajo',
      subtitle: 'Referencias que necesitan revisión o reposición.',
      icon: Icons.warning_amber_outlined,
      child: products.isEmpty
          ? Text(
              'No hay productos por debajo del stock mínimo.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Mínimo')),
                  DataColumn(label: Text('Ubicación')),
                ],
                rows: products.map((product) {
                  return DataRow(
                    cells: [
                      DataCell(Text(product.name)),
                      DataCell(Text(product.sku)),
                      DataCell(Text(product.stock.toString())),
                      DataCell(Text(product.minStock.toString())),
                      DataCell(Text(product.location ?? '-')),
                    ],
                  );
                }).toList(),
              ),
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
    return _SectionCard(
      title: 'Resumen de productos',
      subtitle: 'Listado general con estado de inventario.',
      icon: Icons.inventory_2_outlined,
      child: SingleChildScrollView(
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
                      ? const InventoryStatusChip.lowStock()
                      : const InventoryStatusChip.ok(),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              child,
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  'No se pudieron cargar los datos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
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
  const _Sidebar({
    required this.selectedIndex,
    required this.onProductsSelected,
  });

  final int selectedIndex;
  final VoidCallback onProductsSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundAlt,
        border: Border(
          right: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
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
        onDestinationSelected: (index) {
          if (index == 1) {
            onProductsSelected();
          }
        },
      ),
    );
  }
}
