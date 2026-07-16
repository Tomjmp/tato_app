# Migraciones TÁTO

Archivos SQL listos para aplicar cuando exista un proyecto Supabase — hoy no hay ninguno conectado, el frontend sigue funcionando 100% contra los repositorios mock.

## Orden de aplicación

1. `0001_profiles.sql`
2. `0002_businesses.sql`
3. `0003_categories.sql`
4. `0004_products.sql`
5. `0005_inventory_movements.sql`
6. `0006_functions.sql`
7. `0007_storage.sql`

El orden importa: cada archivo referencia tablas creadas en los anteriores.

## Cómo aplicarlas

Con [Supabase CLI](https://supabase.com/docs/guides/cli) instalado y el proyecto vinculado (`supabase link`):

```
supabase db push
```

O pegando cada archivo, en orden, en el SQL Editor del dashboard de Supabase.

## Después de aplicarlas

Falta (fuera de esta ronda, ver conversación de diseño de backend):

- `Supabase.initialize()` en `main.dart` con la URL y anon key del proyecto.
- Implementaciones `SupabaseXRepository` en Dart para cada repositorio (`AuthRepository`, `BusinessRepository`, `CategoryRepository`, `ProductRepository`, `MovementRepository`) — hoy solo existen los `MockXRepository`.
- Swap en `providers.dart` de `Mock...` a `Supabase...` en cada provider de repositorio.

Ninguna pantalla necesita cambios para ese swap — es exactamente el punto de la capa de repositorios.
