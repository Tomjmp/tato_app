-- `deleted_at` implementa soft delete: un producto con historial de
-- movimientos no puede borrarse duro (ver el `restrict` implícito por no
-- tener `on delete cascade` desde inventory_movements hacia products en
-- 0005) sin perder trazabilidad, así que "eliminar producto" en la UI marca
-- esta columna en vez de hacer un DELETE real.

create table public.products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  category_id uuid references public.categories (id) on delete set null,
  name text not null,
  description text,
  sku text,
  image_url text,
  price numeric(12, 2) not null check (price >= 0),
  cost numeric(12, 2) not null check (cost >= 0),
  current_stock numeric(12, 2) not null default 0 check (current_stock >= 0),
  min_stock_alert numeric(12, 2) not null default 0 check (min_stock_alert >= 0),
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index products_business_id_idx on public.products (business_id);
create index products_category_id_idx on public.products (category_id);

alter table public.products enable row level security;

create policy "El dueño ve los productos de sus negocios"
  on public.products for select
  using (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

create policy "El dueño crea productos en sus negocios"
  on public.products for insert
  with check (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

-- Cubre tanto la edición normal como el "soft delete" (UPDATE de deleted_at)
-- — no hay política de DELETE físico; ver comentario arriba.
create policy "El dueño edita productos de sus negocios"
  on public.products for update
  using (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  )
  with check (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );
