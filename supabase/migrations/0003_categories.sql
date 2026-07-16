-- Categorías de producto, por negocio y editables. Sin seed fijo aquí — el
-- sembrado de las 9 categorías por defecto (Belleza, Alimentos, Bebidas,
-- Cuidado personal, Limpieza, Ropa, Accesorios, Colmado, Otro) lo hace el
-- cliente (SeedDefaultCategoriesUseCase) o la función
-- create_business_with_default_categories (0006_functions.sql), no un
-- INSERT fijo de esta migración.

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  name text not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, name)
);

create index categories_business_id_idx on public.categories (business_id);

alter table public.categories enable row level security;

create policy "El dueño ve las categorías de sus negocios"
  on public.categories for select
  using (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

create policy "El dueño crea categorías en sus negocios"
  on public.categories for insert
  with check (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

create policy "El dueño edita categorías de sus negocios"
  on public.categories for update
  using (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  )
  with check (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

create policy "El dueño elimina categorías de sus negocios"
  on public.categories for delete
  using (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );
