-- Historial de movimientos: append-only por regla de negocio ("Never
-- delete movement history" / "Stock must always be calculated from
-- inventory movements"). No existe política de UPDATE ni DELETE para
-- ningún rol — ni siquiera el dueño del negocio puede editar o borrar un
-- movimiento ya insertado. Es una garantía de la base de datos, no solo
-- una convención del cliente.

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete restrict,
  -- Denormalizado desde products.business_id: evita un JOIN en cada
  -- política RLS de esta tabla (se escribe/lee mucho más que products).
  business_id uuid not null references public.businesses (id) on delete cascade,
  type text not null check (type in ('entry', 'exit', 'adjustment')),
  quantity numeric(12, 2) not null check (quantity > 0),
  reason text not null,
  note text,
  -- Solo tiene sentido cuando type = 'adjustment': si la corrección suma o
  -- resta stock. Null para entry/exit (la dirección ya la da el type).
  increases_stock boolean,
  date timestamptz not null,
  created_at timestamptz not null default now()
);

create index inventory_movements_business_id_idx on public.inventory_movements (business_id);
create index inventory_movements_product_id_idx on public.inventory_movements (product_id);

alter table public.inventory_movements enable row level security;

create policy "El dueño ve los movimientos de sus negocios"
  on public.inventory_movements for select
  using (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

create policy "El dueño registra movimientos en sus negocios"
  on public.inventory_movements for insert
  with check (
    business_id in (select id from public.businesses where owner_id = auth.uid())
  );

-- Sin política de UPDATE ni DELETE — intencional, ver comentario arriba.
-- Cualquier INSERT/UPDATE directo contra esta tabla que intente mover stock
-- debe pasar por register_movement() (0006_functions.sql) para que el
-- recálculo de products.current_stock sea atómico.
