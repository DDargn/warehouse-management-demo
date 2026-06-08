import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    super.key,
    this.initialProduct,
  });

  final ProductModel? initialProduct;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _locationController;
  late final TextEditingController _unitPriceController;

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();

    final product = widget.initialProduct;

    _nameController = TextEditingController(text: product?.name ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _stockController = TextEditingController(text: product?.stock.toString() ?? '0');
    _minStockController = TextEditingController(text: product?.minStock.toString() ?? '0');
    _locationController = TextEditingController(text: product?.location ?? '');
    _unitPriceController = TextEditingController(
      text: product?.unitPrice.toStringAsFixed(2) ?? '0.00',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = ProductPayload(
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      category: _categoryController.text.trim(),
      description: _emptyToNull(_descriptionController.text),
      stock: int.parse(_stockController.text.trim()),
      minStock: int.parse(_minStockController.text.trim()),
      location: _emptyToNull(_locationController.text),
      unitPrice: double.parse(
        _unitPriceController.text.trim().replaceAll(',', '.'),
      ),
    );

    Navigator.of(context).pop(payload);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String? _requiredTextValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    return null;
  }

  String? _nonNegativeIntValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final parsed = int.tryParse(value.trim());

    if (parsed == null) {
      return 'Debe ser un número entero';
    }

    if (parsed < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  String? _nonNegativeDoubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));

    if (parsed == null) {
      return 'Debe ser un número válido';
    }

    if (parsed < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar producto' : 'Crear producto'),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _DialogField(
                  width: 330,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: _requiredTextValidator,
                  ),
                ),
                _DialogField(
                  width: 330,
                  child: TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      border: OutlineInputBorder(),
                    ),
                    validator: _requiredTextValidator,
                  ),
                ),
                _DialogField(
                  width: 330,
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    validator: _requiredTextValidator,
                  ),
                ),
                _DialogField(
                  width: 330,
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                _DialogField(
                  width: 210,
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _nonNegativeIntValidator,
                  ),
                ),
                _DialogField(
                  width: 210,
                  child: TextFormField(
                    controller: _minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock mínimo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _nonNegativeIntValidator,
                  ),
                ),
                _DialogField(
                  width: 210,
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio unitario',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _nonNegativeDoubleValidator,
                  ),
                ),
                SizedBox(
                  width: 680,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.width,
    required this.child,
  });

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: child,
    );
  }
}
