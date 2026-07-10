import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';

/// Static in-memory sample data. Stands in for a backend until Supabase is
/// wired up — every screen in the app should be fully exercisable with
/// just this data.
final class MockData {
  MockData._();

  static final List<Product> products = [
    Product(
      localId: 'prod-001',
      businessId: 'biz-001',
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
      localId: 'prod-002',
      businessId: 'biz-001',
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
      localId: 'prod-003',
      businessId: 'biz-001',
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
      localId: 'prod-004',
      businessId: 'biz-001',
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
      localId: 'prod-005',
      businessId: 'biz-001',
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
      localId: 'prod-006',
      businessId: 'biz-001',
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
      localId: 'prod-007',
      businessId: 'biz-001',
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
      localId: 'prod-008',
      businessId: 'biz-001',
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
      localId: 'prod-009',
      businessId: 'biz-001',
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
      localId: 'prod-010',
      businessId: 'biz-001',
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

  static List<InventoryMovement> get movements {
    final now = DateTime.now();
    DateTime daysAgo(int d, [int h = 0]) =>
        now.subtract(Duration(days: d, hours: h));

    InventoryMovement exit(String id, String name, int day, double qty,
            [String reason = 'Venta']) =>
        InventoryMovement(
          localId: '$id-exit-$day-${qty.toInt()}',
          productId: id,
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
      exit('prod-001', 'Shampoo L\'Oreal Elvive', 0, 2),
      exit('prod-001', 'Shampoo L\'Oreal Elvive', 4, 1),

      // Crema Nivea — steady seller.
      exit('prod-002', 'Crema Hidratante Nivea', 0, 3),
      exit('prod-002', 'Crema Hidratante Nivea', 3, 2),
      exit('prod-002', 'Crema Hidratante Nivea', 6, 3),

      // Esmalte OPI — sold out three days ago.
      exit('prod-003', 'Esmalte OPI', 2, 3),

      // Aceite de Argán — restocked, no sales yet (slow mover).
      InventoryMovement(
        localId: 'prod-004-entry-1',
        productId: 'prod-004',
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
      exit('prod-005', 'Mascarilla de Carbón', 1, 1),

      // Perfume Carolina Herrera — no movement in the window (money locked).

      // CeraVe Hydrating Cleanser — ~2 units/day → depletes in ~3 days
      // with 6 units left. Mirrors the example insight in the product spec.
      exit('prod-007', 'CeraVe Hydrating Cleanser', 1, 3),
      exit('prod-007', 'CeraVe Hydrating Cleanser', 3, 4),
      exit('prod-007', 'CeraVe Hydrating Cleanser', 5, 5),
      exit('prod-007', 'CeraVe Hydrating Cleanser', 7, 4),
      exit('prod-007', 'CeraVe Hydrating Cleanser', 9, 4),
      exit('prod-007', 'CeraVe Hydrating Cleanser', 11, 4),
      exit('prod-007', 'CeraVe Hydrating Cleanser', 13, 4),

      // Refresco Country Club — top seller by volume.
      exit('prod-008', 'Refresco Country Club 2L', 0, 6),
      exit('prod-008', 'Refresco Country Club 2L', 2, 5),
      exit('prod-008', 'Refresco Country Club 2L', 4, 7),
      exit('prod-008', 'Refresco Country Club 2L', 6, 4),
      exit('prod-008', 'Refresco Country Club 2L', 9, 6),

      // Cartera de mano — occasional sale.
      exit('prod-009', 'Cartera de mano', 8, 1, 'Venta'),

      // Llavero decorativo — no movement at all (slow mover).
    ];
  }
}
