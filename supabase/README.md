# Backend de TÁTO — Supabase

Esquema de base de datos, seguridad (RLS) y datos semilla para TÁTO. Corresponde
al issue **#10 — Diseñar modelo y esquema de base de datos** y es la base para la
autenticación, los repositorios reales y la sincronización offline.

## Contenido

```
supabase/
├── migrations/
│   ├── 20260713120000_initial_schema.sql   Tablas, índices y restricciones
│   ├── 20260713120100_rls_policies.sql     Row Level Security por usuario/negocio
│   ├── 20260713120200_triggers.sql         updated_at + creación de perfil
│   └── 20260713120300_seed_categories.sql  Catálogo de categorías
└── README.md
```

## Modelo de datos

```
auth.users (gestionado por Supabase Auth)
   │
   ├── profiles            (1:1)  email, full_name
   └── businesses          (1:N)  name, category, currency
          └── products     (1:N)  price, cost, current_stock, min_stock_alert
                 └── inventory_movements (1:N)  type, quantity, reason, date

categories  (catálogo global, referenciado por products.category_id)
```

## Decisiones de diseño

- **IDs generados por el cliente (offline-first).** El `id` de cada fila es un
  UUID que la app puede generar localmente. Al sincronizar, ese mismo UUID pasa a
  ser el `cloudId` del modelo Dart, así que `localId == cloudId == id`. Evita
  tener que mapear identificadores locales y de nube.
- **Campos de sync solo en el cliente.** `localId`, `cloudId` y `synced` no se
  guardan en la nube: una fila que ya está en Supabase está, por definición,
  sincronizada.
- **`categories` con clave natural en texto.** El `id` es la etiqueta (`'Belleza'`)
  porque `Product.categoryId` almacena la etiqueta, no un UUID. Así el `fromJson`
  de la entidad Dart existente funciona sin cambios.
- **`inventory_movements` es historial de solo-agregado.** RLS permite insertar y
  leer, pero no actualizar ni borrar, para no perder trazabilidad.
- **`current_stock` vive en `products`.** Lo mantiene el cliente (también en modo
  offline); los movimientos son la fuente de verdad histórica. Se evita un trigger
  de stock en la base para no duplicar la lógica que ya corre en la app.

## Cómo crear el proyecto en Supabase

1. Entra a <https://supabase.com>, crea una cuenta gratuita y pulsa **New project**.
2. Nombre: `tato`. Elige una contraseña de base de datos y guárdala.
3. Región: la más cercana (por ejemplo `East US`).
4. Espera a que el proyecto termine de aprovisionarse (~2 min).

### Obtener las credenciales

En **Project Settings → API**:

- **Project URL** → `https://xxxxxxxx.supabase.co`
- **anon public key** → clave larga que empieza con `eyJ...`

Estas dos son las que usará la app en `Supabase.initialize(...)`. La `anon key` es
pública (se protege con RLS); nunca subas la `service_role key` al repositorio.

## Cómo aplicar las migraciones

### Opción A — SQL Editor (rápida, sin instalar nada)

En el panel de Supabase, abre **SQL Editor** y ejecuta el contenido de cada archivo
de `migrations/` **en orden**:

1. `20260713120000_initial_schema.sql`
2. `20260713120100_rls_policies.sql`
3. `20260713120200_triggers.sql`
4. `20260713120300_seed_categories.sql`

### Opción B — Supabase CLI (reproducible)

```bash
# instalar (macOS)
brew install supabase/tap/supabase

# enlazar el proyecto (te pedirá la contraseña de la base de datos)
supabase link --project-ref <tu-project-ref>

# aplicar las migraciones de esta carpeta a la base remota
supabase db push
```

## Cómo verificar que quedó bien

En **Table Editor** deberías ver las 5 tablas y `categories` con 9 filas. Para
comprobar RLS, en **SQL Editor** revisa que todas tengan la política activa:

```sql
select tablename, rowsecurity
from pg_tables
where schemaname = 'public';
```

`rowsecurity` debe ser `true` en las cinco tablas.

## Próximos pasos (backend)

1. Añadir `Supabase.initialize(url, anonKey)` en `main.dart`.
2. Reemplazar el login mock por Supabase Auth (`signUp` / `signInWithPassword`),
   enviando `full_name` en los metadatos para que el trigger arme el perfil.
3. Implementar `SupabaseProductRepository` y `SupabaseMovementRepository` y
   cambiar el swap en `lib/core/services/providers.dart`.
4. Añadir la cola offline (Hive) y el motor de sincronización.
