import 'package:flutter/material.dart';

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
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
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
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
                    return const Center(
                      child: Text('No hay productos para mostrar.'),
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
      elevation: 0,
      child: SwitchListTile(
        title: const Text('Mostrar solo productos con stock bajo'),
        subtitle: const Text('Filtra productos cuyo stock actual está por debajo del mínimo'),
        value: lowStockOnly,
        onChanged: onLowStockOnlyChanged,
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
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
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
                          ? const Chip(
                              label: Text('Stock bajo'),
                              avatar: Icon(Icons.warning_amber, size: 18),
                            )
                          : const Chip(
                              label: Text('OK'),
                              avatar: Icon(Icons.check_circle, size: 18),
                            ),
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
                  'No se pudieron cargar los productos',
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
