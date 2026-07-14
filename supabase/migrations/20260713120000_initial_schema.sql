-- TÁTO — Esquema inicial de base de datos (Supabase / PostgreSQL)
--
-- Tablas: profiles, businesses, categories, products, inventory_movements.
-- El diseño calza con las entidades Dart existentes para que los repositorios
-- reales (SupabaseProductRepository, SupabaseMovementRepository) reemplacen a
-- los mocks sin cambiar la UI.
--
-- Decisiones de diseño relevantes:
--  * El id de cada fila es un UUID que el cliente puede generar localmente
--    (patrón offline-first). Al sincronizar, ese mismo id pasa a ser el
--    cloudId del modelo Dart, por lo que localId == cloudId == id.
--  * Los campos de sincronización del cliente (localId, cloudId, synced) NO se
--    guardan en la nube: una vez que la fila llega a Supabase, ya está
--    sincronizada por definición.
--  * categories usa clave natural en texto (el id es la etiqueta, ej. 'Belleza')
--    porque Product.categoryId almacena la etiqueta, no un UUID.

create extension if not exists "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- profiles: extiende auth.users con los datos que la app necesita del usuario.
-- ─────────────────────────────────────────────────────────────────────────────
create table public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text not null,
  full_name  text,
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- businesses: cada usuario puede tener uno o varios negocios.
-- ─────────────────────────────────────────────────────────────────────────────
create table public.businesses (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null references auth.users (id) on delete cascade,
  name       text not null,
  category   text not null,
  currency   text not null default 'DOP',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint businesses_category_check check (
    category in ('Belleza', 'Alimentos', 'Bebidas', 'Ropa', 'Accesorios', 'Colmado', 'Otro')
  )
);

create index businesses_owner_id_idx on public.businesses (owner_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- categories: catálogo de categorías de producto. Clave natural en texto para
-- que coincida con Product.categoryId, que guarda la etiqueta directamente.
-- ─────────────────────────────────────────────────────────────────────────────
create table public.categories (
  id         text primary key,
  name       text not null,
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- products
-- ─────────────────────────────────────────────────────────────────────────────
create table public.products (
  id              uuid primary key default gen_random_uuid(),
  business_id     uuid not null references public.businesses (id) on delete cascade,
  name            text not null,
  description     text,
  sku             text,
  category_id     text references public.categories (id) on delete set null,
  category_name   text,
  image_url       text,
  price           numeric(12, 2) not null default 0,
  cost            numeric(12, 2) not null default 0,
  current_stock   numeric(12, 2) not null default 0,
  min_stock_alert numeric(12, 2) not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint products_price_nonneg check (price >= 0),
  constraint products_cost_nonneg check (cost >= 0),
  constraint products_stock_nonneg check (current_stock >= 0),
  constraint products_min_stock_nonneg check (min_stock_alert >= 0)
);

create index products_business_id_idx on public.products (business_id);
create index products_category_id_idx on public.products (category_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- inventory_movements: historial de movimientos (entrada, salida, ajuste).
-- Se trata como historial de solo-agregado: las políticas RLS permiten insertar
-- y leer, pero no actualizar ni borrar, para no perder trazabilidad.
-- El stock actual se mantiene en products.current_stock (lo calcula el cliente
-- también en modo offline); los movimientos son la fuente de verdad histórica.
-- ─────────────────────────────────────────────────────────────────────────────
create table public.inventory_movements (
  id              uuid primary key default gen_random_uuid(),
  product_id      uuid not null references public.products (id) on delete cascade,
  product_name    text not null,
  type            text not null,
  quantity        numeric(12, 2) not null,
  reason          text not null default '',
  note            text,
  increases_stock boolean,
  date            timestamptz not null default now(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint movements_type_check check (type in ('entry', 'exit', 'adjustment')),
  constraint movements_quantity_positive check (quantity > 0)
);

create index inventory_movements_product_id_idx on public.inventory_movements (product_id);
create index inventory_movements_date_idx on public.inventory_movements (date);
