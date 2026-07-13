import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';

/// Static in-memory sample data. Stands in for a backend until Supabase is
/// wired up — every screen in the app should be fully exercisable with
/// just this data.
///
/// IDs below are real UUIDs generated once and hardcoded, matching the
/// client-generated-UUID scheme used everywhere else, so the seed data's
/// product↔movement relationships stay stable and reproducible across runs.
final class MockData {
  MockData._();

  static const _bizId = '967d33cb-fc30-4faf-a83f-fc116d89d3c8';

  static const _shampoo = '14040e0b-75f1-4651-b853-1d147c16cc4a';
  static const _crema = 'c624a1d6-bb2b-4de2-961a-5e6427d7d945';
  static const _esmalte = '8a8745ce-c285-431c-8c5b-fffa0f3250c8';
  static const _aceite = 'f03ef763-45fc-466c-9e6b-5e66adfea54d';
  static const _mascarilla = '913ff00d-14ca-49df-9ab8-b9b3beb81d97';
  static const _perfume = 'df82f773-8727-4c24-9823-25c743f32749';
  static const _cerave = '27305d35-7d46-44e4-985e-f89c3800d1d8';
  static const _refresco = 'f4b7a3c3-195f-44f7-aebe-b3973ec6d35b';
  static const _cartera = 'ea59efd8-abe0-41f7-bb89-6529f6c20538';
  static const _llavero = '3deae3fd-19de-4d38-aef4-757cfd1459dc';

  static final List<Product> products = [
    Product(
      id: _shampoo,
      businessId: _bizId,
      name: 'Shampoo L\'Oreal Elvive',
      description: 'Shampoo reparación total 400ml',
      sku: 'SH-001',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 450,
      cost: 280,
      currentStock: 3,
      minStockAlert: 5,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 7, 9),
      synced: false,
    ),
    Product(
      id: _crema,
      businessId: _bizId,
      name: 'Crema Hidratante Nivea',
      description: 'Crema corporal 200ml',
      sku: 'CR-002',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 320,
      cost: 180,
      currentStock: 12,
      minStockAlert: 5,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 7, 8),
      synced: false,
    ),
    Product(
      id: _esmalte,
      businessId: _bizId,
      name: 'Esmalte OPI',
      description: 'Esmalte de uñas colección coral',
      sku: 'ES-003',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 550,
      cost: 320,
      currentStock: 0,
      minStockAlert: 3,
      createdAt: DateTime(2026, 6, 5),
      updatedAt: DateTime(2026, 7, 7),
      synced: false,
    ),
    Product(
      id: _aceite,
      businessId: _bizId,
      name: 'Aceite de Argán',
      description: 'Aceite tratamiento capilar 100ml',
      sku: 'AC-004',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 750,
      cost: 450,
      currentStock: 8,
      minStockAlert: 3,
      createdAt: DateTime(2026, 6, 10),
      updatedAt: DateTime(2026, 7, 9),
      synced: false,
    ),
    Product(
      id: _mascarilla,
      businessId: _bizId,
      name: 'Mascarilla de Carbón',
      description: 'Mascarilla facial purificante 50ml',
      sku: 'MC-005',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 420,
      cost: 220,
      currentStock: 2,
      minStockAlert: 4,
      createdAt: DateTime(2026, 6, 15),
      updatedAt: DateTime(2026, 7, 9),
      synced: false,
    ),
    Product(
      id: _perfume,
      businessId: _bizId,
      name: 'Perfume Carolina Herrera 212',
      description: 'Eau de Toilette 100ml',
      sku: 'PF-006',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 3200,
      cost: 2100,
      currentStock: 5,
      minStockAlert: 2,
      createdAt: DateTime(2026, 6, 20),
      updatedAt: DateTime(2026, 7, 5),
      synced: false,
    ),
    Product(
      id: _cerave,
      businessId: _bizId,
      name: 'CeraVe Hydrating Cleanser',
      description: 'Limpiador facial hidratante 236ml',
      sku: 'CV-007',
      categoryId: 'Belleza',
      categoryName: 'Belleza',
      price: 980,
      cost: 610,
      currentStock: 6,
      minStockAlert: 4,
      createdAt: DateTime(2026, 6, 12),
      updatedAt: DateTime(2026, 7, 9),
      synced: false,
    ),
    Product(
      id: _refresco,
      businessId: _bizId,
      name: 'Refresco Country Club 2L',
      description: 'Bebida gaseosa sabor cola',
      sku: 'BB-008',
      categoryId: 'Bebidas',
      categoryName: 'Bebidas',
      price: 120,
      cost: 70,
      currentStock: 20,
      minStockAlert: 6,
      createdAt: DateTime(2026, 6, 3),
      updatedAt: DateTime(2026, 7, 9),
      synced: false,
    ),
    Product(
      id: _cartera,
      businessId: _bizId,
      name: 'Cartera de mano',
      description: 'Cartera sintética negra',
      sku: 'AX-009',
      categoryId: 'Accesorios',
      categoryName: 'Accesorios',
      price: 1450,
      cost: 900,
      currentStock: 4,
      minStockAlert: 2,
      createdAt: DateTime(2026, 6, 8),
      updatedAt: DateTime(2026, 7, 1),
      synced: false,
    ),
    Product(
      id: _llavero,
      businessId: _bizId,
      name: 'Llavero decorativo',
      description: 'Llavero artesanal variado',
      sku: 'AX-010',
      categoryId: 'Accesorios',
      categoryName: 'Accesorios',
      price: 150,
      cost: 60,
      currentStock: 15,
      minStockAlert: 5,
      createdAt: DateTime(2026, 6, 8),
      updatedAt: DateTime(2026, 6, 8),
      synced: false,
    ),
  ];

  static final List<String> _movementIds = [
    '83c34479-5fef-4bb2-9e92-bec383226389',
    '944a6657-110f-40ec-bec4-5d0e43d2cacf',
    '44472fef-bc6d-418e-9599-008e3e6a65b6',
    'fcfc2995-173f-4d51-8540-127b7cfb2161',
    '8b74fc36-0e2a-4f7c-ac98-9ebf1de5fe61',
    '7c5067ce-0cda-411a-acbd-461ba524869e',
    'a373e97b-6d52-4df9-bb8c-e627b4e972b0',
    '2ff79ce3-4e1d-44bd-b7dd-ecf49b2bfab3',
    '36e96dc1-05db-4907-84ff-e28573ecbbd4',
    'a3b96ddc-2510-4b47-8e13-13ca15821593',
    '7ea5e907-2044-4c11-a559-923aaff461fd',
    'f0571bb0-dcab-4758-8cee-e6816d40978b',
    '4bfe4dec-9dc2-44b7-a593-732e03bfa73f',
    'f39dfbf6-404d-462b-97e8-43f8d25642dc',
    '80232b0d-2a29-449f-b997-94048ab2c62c',
    'bd9a085b-0374-4e67-9d25-d35e7b8a0759',
    'fdef8742-8c76-4f57-b768-be2515d0566a',
    '77a7c9eb-fcbf-497e-8305-885f5069ccc6',
    '7dbfa058-91bb-4d7a-8e91-1fc7d42842e5',
    '359623f1-a9a9-450e-928d-f8a1c88ceb0b',
    '4e0a1962-a37b-4c02-b226-81a57ca0388d',
  ];

  static List<InventoryMovement> get movements {
    final now = DateTime.now();
    DateTime daysAgo(int d, [int h = 0]) =>
        now.subtract(Duration(days: d, hours: h));

    var nextId = 0;
    InventoryMovement exit(String productId, String name, int day, double qty,
            [String reason = 'Venta']) =>
        InventoryMovement(
          id: _movementIds[nextId++],
          productId: productId,
          productName: name,
          type: MovementType.exit,
          quantity: qty,
          reason: reason,
          date: daysAgo(day),
          createdAt: daysAgo(day),
          updatedAt: daysAgo(day),
          synced: false,
        );

    return [
      // Shampoo — a couple of recent sales, explains the low stock alert.
      exit(_shampoo, 'Shampoo L\'Oreal Elvive', 0, 2),
      exit(_shampoo, 'Shampoo L\'Oreal Elvive', 4, 1),

      // Crema Nivea — steady seller.
      exit(_crema, 'Crema Hidratante Nivea', 0, 3),
      exit(_crema, 'Crema Hidratante Nivea', 3, 2),
      exit(_crema, 'Crema Hidratante Nivea', 6, 3),

      // Esmalte OPI — sold out three days ago.
      exit(_esmalte, 'Esmalte OPI', 2, 3),

      // Aceite de Argán — restocked, no sales yet (slow mover).
      InventoryMovement(
        id: _movementIds[nextId++],
        productId: _aceite,
        productName: 'Aceite de Argán',
        type: MovementType.entry,
        quantity: 10,
        reason: 'Compra',
        date: daysAgo(1),
        createdAt: daysAgo(1),
        updatedAt: daysAgo(1),
        synced: false,
      ),

      // Mascarilla de Carbón — one recent sale, still low stock.
      exit(_mascarilla, 'Mascarilla de Carbón', 1, 1),

      // Perfume Carolina Herrera — no movement in the window (money locked).

      // CeraVe Hydrating Cleanser — ~2 units/day → depletes in ~3 days
      // with 6 units left. Mirrors the example insight in the product spec.
      exit(_cerave, 'CeraVe Hydrating Cleanser', 1, 3),
      exit(_cerave, 'CeraVe Hydrating Cleanser', 3, 4),
      exit(_cerave, 'CeraVe Hydrating Cleanser', 5, 5),
      exit(_cerave, 'CeraVe Hydrating Cleanser', 7, 4),
      exit(_cerave, 'CeraVe Hydrating Cleanser', 9, 4),
      exit(_cerave, 'CeraVe Hydrating Cleanser', 11, 4),
      exit(_cerave, 'CeraVe Hydrating Cleanser', 13, 4),

      // Refresco Country Club — top seller by volume.
      exit(_refresco, 'Refresco Country Club 2L', 0, 6),
      exit(_refresco, 'Refresco Country Club 2L', 2, 5),
      exit(_refresco, 'Refresco Country Club 2L', 4, 7),
      exit(_refresco, 'Refresco Country Club 2L', 6, 4),
      exit(_refresco, 'Refresco Country Club 2L', 9, 6),

      // Cartera de mano — occasional sale.
      exit(_cartera, 'Cartera de mano', 8, 1, 'Venta'),

      // Llavero decorativo — no movement at all (slow mover).
    ];
  }
}
