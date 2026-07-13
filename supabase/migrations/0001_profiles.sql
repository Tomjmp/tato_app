-- Perfil público del usuario, 1:1 con auth.users (gestionado por Supabase
-- Auth). No se agregan columnas propias a auth.users — este es el patrón
-- estándar de Supabase para datos de perfil específicos de la app.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Los usuarios ven su propio perfil"
  on public.profiles for select
  using (id = auth.uid());

create policy "Los usuarios actualizan su propio perfil"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

-- No hay política de INSERT/DELETE para el usuario: el perfil se crea solo
-- vía el trigger de abajo al registrarse, y se borra en cascada si se borra
-- el usuario de auth.users.

-- Crea automáticamente la fila de profiles al registrarse un usuario nuevo.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name)
  values (new.id, new.email, new.raw_user_meta_data ->> 'name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
