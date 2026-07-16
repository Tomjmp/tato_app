-- Bucket para fotos de producto. Ruta esperada de cada archivo:
--   {business_id}/{product_id}/{filename}
-- Las políticas verifican que el primer segmento de la ruta (business_id)
-- pertenezca a un negocio del usuario autenticado — mismo criterio que las
-- políticas de las tablas.

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

create policy "El dueño ve las fotos de sus negocios"
  on storage.objects for select
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1]::uuid in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );

create policy "El dueño sube fotos a sus negocios"
  on storage.objects for insert
  with check (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1]::uuid in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );

create policy "El dueño reemplaza fotos de sus negocios"
  on storage.objects for update
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1]::uuid in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );

create policy "El dueño elimina fotos de sus negocios"
  on storage.objects for delete
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1]::uuid in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );
