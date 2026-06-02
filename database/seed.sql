INSERT INTO products 
(name, sku, category, description, stock, min_stock, location, unit_price)
VALUES
('Motor eléctrico', 'MOT-001', 'Repuestos', 'Motor eléctrico para sistemas de elevación.', 12, 5, 'A1', 249.90),
('Sensor de puerta', 'SEN-014', 'Sensores', 'Sensor de seguridad para apertura y cierre de puertas.', 4, 10, 'B2', 39.50),
('Cable de acero 10mm', 'CAB-010', 'Material', 'Cable de acero de alta resistencia.', 30, 15, 'C1', 12.75),
('Cuadro de maniobra', 'CUA-100', 'Electrónica', 'Cuadro de control para sistemas industriales.', 2, 3, 'D4', 899.00),
('Rodamiento industrial', 'ROD-022', 'Mecánica', 'Rodamiento para maquinaria pesada.', 18, 8, 'A3', 24.80),
('Botonera exterior', 'BOT-006', 'Componentes', 'Botonera de llamada para instalación exterior.', 7, 6, 'B1', 58.00),
('Guía metálica', 'GUI-030', 'Material', 'Guía metálica para estructura de soporte.', 20, 10, 'C3', 35.25),
('Fuente de alimentación', 'FUE-012', 'Electrónica', 'Fuente de alimentación 24V.', 5, 4, 'D2', 75.40);

INSERT INTO stock_movements
(product_id, movement_type, quantity, reason)
VALUES
(1, 'IN', 12, 'Carga inicial de inventario'),
(2, 'IN', 4, 'Carga inicial de inventario'),
(3, 'IN', 30, 'Carga inicial de inventario'),
(4, 'IN', 2, 'Carga inicial de inventario'),
(5, 'IN', 18, 'Carga inicial de inventario'),
(6, 'IN', 7, 'Carga inicial de inventario'),
(7, 'IN', 20, 'Carga inicial de inventario'),
(8, 'IN', 5, 'Carga inicial de inventario'),

(2, 'OUT', 2, 'Salida para reparación'),
(3, 'OUT', 5, 'Uso en mantenimiento'),
(5, 'OUT', 3, 'Salida para instalación'),
(1, 'IN', 4, 'Reposición de proveedor');
