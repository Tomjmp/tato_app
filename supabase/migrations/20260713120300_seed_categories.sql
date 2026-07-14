-- TÁTO — Datos semilla del catálogo de categorías de producto.
--
-- El id es la etiqueta en texto (clave natural) para calzar con Product.categoryId.
-- Incluye las categorías de producto de la propuesta más las que usan los tipos
-- de negocio, de modo que ningún valor que envíe la app quede sin referencia.
-- Idempotente: se puede volver a ejecutar sin duplicar filas.

insert into public.categories (id, name) values
  ('Alimentos',        'Alimentos'),
  ('Bebidas',          'Bebidas'),
  ('Cuidado personal', 'Cuidado personal'),
  ('Belleza',          'Belleza'),
  ('Limpieza',         'Limpieza'),
  ('Ropa',             'Ropa'),
  ('Accesorios',       'Accesorios'),
  ('Colmado',          'Colmado'),
  ('Otro',             'Otro')
on conflict (id) do nothing;
