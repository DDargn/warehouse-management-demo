import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../dashboard/data/warehouse_repository.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_form_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final WarehouseRepository _repository = WarehouseRepository();

  late Future<List<ProductModel>> _productsFuture;

  bool _lowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = _repository.getProducts(lowStockOnly: _lowStockOnly);
  }

  void _reloadProducts() {
    setState(_loadProducts);
  }

  Future<void> _openCreateDialog() async {
    final payload = await showDialog<ProductPayload>(
      context: context,
      builder: (context) {
        return const ProductFormDialog();
      },
    );

    if (payload == null) {
      return;
    }

    try {
      await _repository.createProduct(payload);
      _showSuccessMessage('Producto creado correctamente');
      _reloadProducts();
    } catch (error) {
      _showErrorMessage(error.toString());
    }
  }

  Future<void> _openEditDialog(ProductModel product) async {
    final payload = await showDialog<ProductPayload>(
      context: context,
      builder: (context) {
        return ProductFormDialog(initialProduct: product);
      },
    );

    if (payload == null) {
      return;
    }

    try {
      await _repository.updateProduct(
        productId: product.id,
        payload: payload,
      );
      _showSuccessMessage('Producto actualizado correctamente');
      _reloadProducts();
    } catch (error) {
      _showErrorMessage(error.toString());
    }
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text(
            '¿Seguro que quieres eliminar "${product.name}"? '
            'El backend hará un borrado lógico.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.deleteProduct(product.id);
      _showSuccessMessage('Producto eliminado correctamente');
      _reloadProducts();
    } catch (error) {
      _showErrorMessage(error.toString());
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.danger,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _toggleLowStockOnly(bool value) {
    setState(() {
      _lowStockOnly = value;
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de productos'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _reloadProducts,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductsHeader(
                onCreateProduct: _openCreateDialog,
              ),
              const SizedBox(height: 18),
              _ProductsToolbar(
                lowStockOnly: _lowStockOnly,
                onLowStockOnlyChanged: _toggleLowStockOnly,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<ProductModel>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _ErrorState(
                        error: snapshot.error.toString(),
                        onRetry: _reloadProducts,
                      );
                    }

                    final products = snapshot.data ?? [];

                    if (products.isEmpty) {
                      return _EmptyState(
                        lowStockOnly: _lowStockOnly,
                        onCreateProduct: _openCreateDialog,
                      );
                    }

                    return _ProductsTable(
                      products: products,
                      onEdit: _openEditDialog,
                      onDelete: _confirmDelete,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({
    required this.onCreateProduct,
  });

  final VoidCallback onCreateProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102838),
            Color(0xFF0A1720),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos del almacén',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea, edita, filtra y controla las referencias del inventario desde una tabla conectada a FastAPI.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreateProduct,
            icon: const Icon(Icons.add),
            label: const Text('Crear producto'),
          ),
        ],
      ),
    );
  }
}

class _ProductsToolbar extends StatelessWidget {
  const _ProductsToolbar({
    required this.lowStockOnly,
    required this.onLowStockOnlyChanged,
  });

  final bool lowStockOnly;
  final ValueChanged<bool> onLowStockOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SwitchListTile(
          secondary: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.warningSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_outlined,
              color: AppTheme.warning,
            ),
          ),
          title: const Text('Mostrar solo productos con stock bajo'),
          subtitle: const Text(
            'Filtra productos cuyo stock actual está por debajo del mínimo',
          ),
          value: lowStockOnly,
          onChanged: onLowStockOnlyChanged,
        ),
      ),
    );
  }
}

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Listado de productos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${products.length} productos visibles',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('SKU')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Mín.')),
                    DataColumn(label: Text('Ubicación')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Acciones')),
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
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: () => onEdit(product),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () => onDelete(product),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.lowStockOnly,
    required this.onCreateProduct,
  });

  final bool lowStockOnly;
  final VoidCallback onCreateProduct;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 52,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  lowStockOnly
                      ? 'No hay productos con stock bajo'
                      : 'No hay productos para mostrar',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  lowStockOnly
                      ? 'Desactiva el filtro para ver el inventario completo.'
                      : 'Crea una nueva referencia para empezar a trabajar con el inventario.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onCreateProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo producto'),
                ),
              ],
            ),
          ),
        ),
      ),
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
                  'No se pudieron cargar los productos',
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
