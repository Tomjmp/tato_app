-- Un usuario puede tener varios negocios (1:N). El MVP del frontend solo
-- opera con un negocio activo a la vez, pero no se impone una restricción
-- 1:1 aquí — agregar un selector de negocio en el futuro no requiere tocar
-- este esquema.

create table public.businesses (
  id uuid primary key default gen_random_uuid(), -- Flutter siempre provee el suyo
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  -- Tipo de negocio elegido una vez en el onboarding. Lista fija, distinta
  -- de las categorías de producto (ver 0003_categories.sql).
  category text not null check (
    category in (
      'Belleza', 'Alimentos', 'Bebidas', 'Ropa',
      'Accesorios', 'Colmado', 'Otro'
    )
  ),
  currency text not null default 'DOP',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index businesses_owner_id_idx on public.businesses (owner_id);

alter table public.businesses enable row level security;

create policy "El dueño ve sus negocios"
  on public.businesses for select
  using (owner_id = auth.uid());

create policy "El dueño crea sus negocios"
  on public.businesses for insert
  with check (owner_id = auth.uid());

create policy "El dueño actualiza sus negocios"
  on public.businesses for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "El dueño elimina sus negocios"
  on public.businesses for delete
  using (owner_id = auth.uid());
