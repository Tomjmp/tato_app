-- TÁTO — Seguridad a nivel de fila (Row Level Security)
--
-- Cada usuario solo puede ver y modificar los datos de sus propios negocios.
-- El catálogo de categorías es de lectura global para usuarios autenticados.
-- Los movimientos son historial de solo-agregado: se permite insertar y leer,
-- pero no actualizar ni borrar.

alter table public.profiles            enable row level security;
alter table public.businesses          enable row level security;
alter table public.categories          enable row level security;
alter table public.products            enable row level security;
alter table public.inventory_movements enable row level security;

-- ─── profiles ────────────────────────────────────────────────────────────────
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- ─── businesses ──────────────────────────────────────────────────────────────
create policy "businesses_select_own" on public.businesses
  for select using (auth.uid() = owner_id);

create policy "businesses_insert_own" on public.businesses
  for insert with check (auth.uid() = owner_id);

create policy "businesses_update_own" on public.businesses
  for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "businesses_delete_own" on public.businesses
  for delete using (auth.uid() = owner_id);

-- ─── categories: catálogo global de solo lectura ─────────────────────────────
create policy "categories_select_all" on public.categories
  for select to authenticated using (true);

-- ─── products: acotados a los negocios del usuario ───────────────────────────
create policy "products_select_own" on public.products
  for select using (
    exists (
      select 1 from public.businesses b
      where b.id = products.business_id and b.owner_id = auth.uid()
    )
  );

create policy "products_insert_own" on public.products
  for insert with check (
    exists (
      select 1 from public.businesses b
      where b.id = products.business_id and b.owner_id = auth.uid()
    )
  );

create policy "products_update_own" on public.products
  for update using (
    exists (
      select 1 from public.businesses b
      where b.id = products.business_id and b.owner_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.businesses b
      where b.id = products.business_id and b.owner_id = auth.uid()
    )
  );

create policy "products_delete_own" on public.products
  for delete using (
    exists (
      select 1 from public.businesses b
      where b.id = products.business_id and b.owner_id = auth.uid()
    )
  );

-- ─── inventory_movements: solo lectura e inserción (historial inmutable) ──────
create policy "movements_select_own" on public.inventory_movements
  for select using (
    exists (
      select 1
      from public.products p
      join public.businesses b on b.id = p.business_id
      where p.id = inventory_movements.product_id and b.owner_id = auth.uid()
    )
  );

create policy "movements_insert_own" on public.inventory_movements
  for insert with check (
    exists (
      select 1
      from public.products p
      join public.businesses b on b.id = p.business_id
      where p.id = inventory_movements.product_id and b.owner_id = auth.uid()
    )
  );
