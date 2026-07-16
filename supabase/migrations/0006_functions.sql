-- Funciones RPC para las dos operaciones que necesitan atomicidad real,
-- no solo tablas + RLS. SECURITY INVOKER (el default): corren con los
-- permisos de quien llama, así que las políticas RLS de arriba se siguen
-- aplicando normalmente — no hay escalación de privilegios aquí.

-- ─────────────────────────────────────────────────────────────────────────
-- register_movement: reemplaza el patrón actual del cliente de "leer
-- producto → calcular → escribir movimiento → escribir producto" en dos
-- llamadas separadas, que bajo concurrencia real (dos dispositivos
-- vendiendo el mismo producto casi al mismo tiempo) puede dejar el stock
-- en negativo pese a que cada llamada individualmente "validó" contra un
-- valor ya desactualizado. Todo ocurre en una sola transacción, con el
-- producto bloqueado (`for update`) mientras se recalcula.
-- ─────────────────────────────────────────────────────────────────────────
create function public.register_movement(
  p_id uuid,
  p_product_id uuid,
  p_type text,
  p_quantity numeric,
  p_reason text,
  p_note text default null,
  p_increases_stock boolean default null,
  p_date timestamptz default now()
)
returns public.products
language plpgsql
security invoker
as $$
declare
  v_product public.products;
  v_delta numeric;
  v_new_stock numeric;
begin
  if p_quantity <= 0 then
    raise exception 'La cantidad debe ser mayor a cero.';
  end if;

  if p_type not in ('entry', 'exit', 'adjustment') then
    raise exception 'Tipo de movimiento inválido.';
  end if;

  -- Bloquea la fila del producto hasta que termine la transacción: una
  -- segunda llamada concurrente para el mismo producto espera aquí en vez
  -- de leer un current_stock que está por quedar desactualizado.
  select * into v_product
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception 'El producto seleccionado no existe.';
  end if;

  v_delta := case p_type
    when 'entry' then p_quantity
    when 'exit' then -p_quantity
    when 'adjustment' then
      case when coalesce(p_increases_stock, true) then p_quantity else -p_quantity end
  end;

  v_new_stock := v_product.current_stock + v_delta;

  if v_new_stock < 0 then
    raise exception 'No hay suficiente stock disponible para esta salida.';
  end if;

  insert into public.inventory_movements (
    id, product_id, business_id, type, quantity, reason, note,
    increases_stock, date
  ) values (
    p_id, p_product_id, v_product.business_id, p_type, p_quantity, p_reason,
    p_note, p_increases_stock, p_date
  );

  update public.products
  set current_stock = v_new_stock, updated_at = now()
  where id = p_product_id
  returning * into v_product;

  return v_product;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- create_business_with_default_categories: crea el negocio y sus 9
-- categorías por defecto en una sola transacción, para que nunca exista un
-- negocio sin categorías básicas para elegir en Stock/ProductForm/Scanner.
-- ─────────────────────────────────────────────────────────────────────────
create function public.create_business_with_default_categories(
  p_id uuid,
  p_name text,
  p_category text
)
returns public.businesses
language plpgsql
security invoker
as $$
declare
  v_business public.businesses;
  v_default_category text;
  v_default_categories text[] := array[
    'Belleza', 'Alimentos', 'Bebidas', 'Cuidado personal',
    'Limpieza', 'Ropa', 'Accesorios', 'Colmado', 'Otro'
  ];
begin
  insert into public.businesses (id, owner_id, name, category)
  values (p_id, auth.uid(), p_name, p_category)
  returning * into v_business;

  foreach v_default_category in array v_default_categories loop
    insert into public.categories (business_id, name, is_default)
    values (v_business.id, v_default_category, true);
  end loop;

  return v_business;
end;
$$;
