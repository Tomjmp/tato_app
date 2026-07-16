# TÁTO — Sistema de diseño

Versión 1.0 · Julio 2026

Este documento define la identidad visual y la especificación UX/UI de TÁTO. Es la referencia para el prototipo en Figma, para la implementación de pantallas en Flutter y para cualquier pieza de comunicación (landing, pitch, demo).

Contenido relacionado:

- Assets del logo: `design/brand/`
- Mockups navegables de las 10 pantallas: `design/mockups/tato_uxui.html` (abrir en el navegador)

---

## 1. Marca

### Concepto

TÁTO viene de "tá to' bien". La marca gira en torno a una idea: **TÁTO está pendiente por ti**. No es un sistema que el usuario revisa; es un asistente que avisa.

### Logo

El símbolo es un monograma **"tt"**: las dos T de TÁTO unidas por una barra cruzada continua.

Lectura del símbolo:

| Elemento | Significado |
| --- | --- |
| Barra continua | El estante que sostiene el inventario; también el gesto de "todo bajo control" |
| Pies curvos de las astas | Tono cercano y humano (minúscula), no corporativo |
| Punto menta flotante | La firma de la marca: "TÁTO notó algo". Es el mismo punto de notificación que usa la app |

### Archivos

| Archivo | Uso |
| --- | --- |
| `brand/tato_mark.svg` | Símbolo en tinta sobre fondos claros |
| `brand/tato_mark_blanco.svg` | Símbolo en blanco sobre azul o fondos oscuros |
| `brand/tato_app_icon.svg` | Ícono de la app (tile azul, esquinas 27/120) |
| `brand/tato_logo_lockup.svg` | Símbolo + wordmark + eslogan (requiere tener la fuente Space Grotesk) |

### Reglas de uso

- El wordmark siempre se escribe **TÁTO** (nunca TATÓ, nunca Tato) en Space Grotesk Bold.
- El punto menta nunca se elimina ni cambia de color: es parte del símbolo.
- Zona de seguridad: dejar alrededor del símbolo un espacio mínimo igual al diámetro del punto menta.
- No rotar, no inclinar, no aplicar degradados ni sombras, no cambiar las proporciones.
- Sobre fotos o fondos con ruido, usar el símbolo dentro del tile azul (versión ícono de app).

---

## 2. Color

### Paleta principal

Cada color tiene un rol semántico fijo. El usuario aprende el lenguaje de color una vez y lo lee en toda la app.

| Nombre | Hex | Rol |
| --- | --- | --- |
| Azul eléctrico | `#1D4ED8` | Marca, botones primarios, tab activa, botón de escanear |
| Tinta | `#0F172A` | Texto principal, selección neutra (chips de filtro activos) |
| Menta | `#14B8A6` | Éxito, sincronizado, en stock, entradas de inventario |
| Lila | `#8B5CF6` | Valor inteligente: dinero inmovilizado, plan Pro |
| Ámbar | `#F59E0B` | Alerta media: bajo stock, necesita atención |
| Coral | `#EF4444` | Alerta alta: agotado, riesgo, salidas |
| Niebla | `#F8FAFC` | Fondo de pantallas |

### Tintes de estado (fondo + texto)

Para badges, tarjetas de métrica y estados. El texto siempre usa el tono oscuro de la misma familia, nunca negro ni gris genérico.

| Estado | Fondo | Texto |
| --- | --- | --- |
| En stock / éxito | `#CCFBF1` | `#0F5C4E` |
| Bajo stock / atención | `#FEF3C7` | `#92400E` |
| Agotado / riesgo | `#FEE2E2` | `#991B1B` |
| Informativo | `#DBEAFE` | `#1E3A8A` |
| Insight / Pro | `#EDE9FE` | `#5B21B6` |
| Categoría Belleza | `#FCE7F3` | `#9D174D` |
| Neutro | `#F1F5F9` | `#475569` |

### Neutros de interfaz

| Uso | Hex |
| --- | --- |
| Texto secundario | `#64748B` |
| Texto deshabilitado / placeholder | `#94A3B8` |
| Bordes | `#E2E8F0` |
| Relleno de inputs | `#EEF2F7` |
| Superficie de tarjetas | `#FFFFFF` |

### Reglas

- El azul es solo para acción. Si todo es azul, nada es importante.
- Ámbar y coral nunca intercambian roles: ámbar = media, coral = alta.
- El lila es exclusivo de insights y Pro; no se usa como decoración.
- El color nunca es el único portador de significado: todo badge lleva texto.

---

## 3. Tipografía

Dos familias con roles claros (disponibles en Google Fonts):

| Familia | Rol |
| --- | --- |
| **Space Grotesk** | Titulares, números y métricas. Los datos son los protagonistas |
| **Inter** | Cuerpo, etiquetas, botones y todo lo demás |

### Escala

| Estilo | Familia | Tamaño / peso | Uso |
| --- | --- | --- | --- |
| Display | Space Grotesk | 28 / 700 | Métrica héroe (dinero inmovilizado) |
| Título pantalla | Space Grotesk | 22–24 / 700 | Encabezado de cada pantalla |
| Métrica | Space Grotesk | 20 / 700 | Números en tarjetas |
| Título tarjeta | Inter | 14 / 600 | Encabezados de sección |
| Cuerpo | Inter | 15 / 400 | Texto general |
| Fila de lista | Inter | 13 / 600 | Nombre de producto |
| Etiqueta | Inter | 12 / 600 | Labels de formulario, chips |
| Detalle | Inter | 11.5 / 400 | Texto secundario de filas |

### Reglas

- Nada por debajo de 11 px.
- Cuerpo con interlineado 1.45 o mayor.
- Labels de formulario siempre en peso 600.
- Los números importantes (stock, días, dinero) van grandes y en Space Grotesk 700.

---

## 4. Fundamentos

| Token | Valor |
| --- | --- |
| Radio de tarjetas y botones | 16 px |
| Radio de inputs y tiles | 14 px |
| Radio de tarjetas héroe | 20 px |
| Radio de chips y badges | 999 px (pill) |
| Radio de hojas modales (bottom sheet) | 28 px arriba |
| Espaciado base | Múltiplos de 4: 8 / 12 / 16 / 18 / 24 |
| Margen lateral de pantalla | 18 px |
| Altura de botón primario | 50–52 px |
| Área táctil mínima | 44 × 44 px |
| Iconografía | Tabler Icons (outline), 20 px en navegación, 16–17 px inline |
| Elevación | Plana: bordes de 1 px (`#EEF2F7`) en lugar de sombras |

Estilo general: color plano sin degradados, esquinas muy redondeadas, pills en vez de dropdowns donde haya 7 opciones o menos, números grandes, espacios generosos.

---

## 5. Componentes

### Botón primario
Fondo azul `#1D4ED8`, texto blanco 14/600, radio 16, alto 50–52. Uno solo por pantalla.

### Botón secundario
Fondo blanco, borde 1.5 px `#E2E8F0`, texto tinta 14/600, mismas dimensiones.

### Chip (filtro y selección)
Pill con borde 1.5 px `#E2E8F0`, texto 12/600 `#334155`, padding 7×12. Estados activos: tinta (filtros neutros) o azul (selección en formularios). Los filtros de urgencia (Bajo stock) usan el tinte ámbar.

### Badge de estado
Pill compacta 11/700, padding 3×9, con los tintes de estado de la sección 2. Estados de stock: En stock (menta), Bajo stock (ámbar), Agotado (coral).

### Input
Relleno `#EEF2F7`, radio 14, padding 13×14, ícono a la izquierda 17 px, placeholder `#94A3B8` 13/500. Variante de selector: fondo blanco con borde y chevron.

### Stepper de cantidad
Botones circulares de 46 px (− blanco con borde, + azul), número central en Space Grotesk 40–42/700.

### Control segmentado
Contenedor `#EEF2F7` radio 16 con padding 4; segmento activo en tinta con texto blanco, radio 12.

### Fila de producto
Tarjeta blanca radio 16, borde 1 px `#EEF2F7`, padding 10×12. Estructura: tile de 40–42 px con inicial y tinte de categoría + nombre 13/600 y detalle 11.5 + estado a la derecha (stock y/o badge).

### Tarjeta de métrica
Tinte de estado, radio 16, padding 10: número Grotesk 20/700 + etiqueta 11/600, ambos en tonos oscuros de la misma familia.

### Tarjeta héroe ("TÁTO notó esto")
Fondo azul pleno, radio 20, padding 14×16: kicker 12/700 con ícono sparkles, mensaje 14.5/600, acción 12.5/600 al 85% de blanco. En Insights, la variante lila (dinero inmovilizado).

### Navegación inferior
5 posiciones: Hoy, Inventario, Escanear (central), Insights, Perfil. Ítems con ícono 20 px + label 11/600; activo azul, inactivo `#94A3B8`. El botón de escanear es un tile azul de 46 px elevado 26 px sobre la barra, con borde del color del fondo: es la feature diferenciadora y ocupa el lugar del pulgar.

---

## 6. Especificación de pantallas

### 01 · Splash y onboarding
- **Objetivo:** presentar la marca y su promesa en una línea.
- **Estructura:** fondo azul pleno → símbolo blanco grande → wordmark TÁTO 40–42 → eslogan al 78% de blanco → 3 badges translúcidos con los diferenciadores (Offline, IA on-device, Alertas) → indicador de página → botón blanco "Empezar".
- **Comportamiento:** máximo 3 slides de onboarding; siempre se puede saltar. Si hay sesión activa, se salta directo a Hoy.

### 02 · Login y registro
- **Objetivo:** entrar con la menor fricción posible.
- **Estructura:** símbolo pequeño → "Hola de nuevo" 26 → correo → contraseña (con mostrar/ocultar) → recuperar contraseña → botón primario "Iniciar sesión" → divisor "o" → botón secundario "Crear cuenta gratis" → badge menta "Funciona sin internet" como generador de confianza.
- **Validaciones:** formato de correo; errores en lenguaje claro bajo el campo, nunca excepciones crudas.
- **Estados:** cargando (botón con spinner, deshabilitado), error de credenciales, sin conexión (mensaje que explica que el login inicial requiere internet).

### 03 · Crear negocio
- **Objetivo:** registrar el negocio para personalizar categorías y alertas.
- **Estructura:** indicador "Paso 2 de 2" con barra de progreso → "Crea tu negocio" 24 → nombre (input) → tipo de negocio en chips con ícono (Belleza, Alimentos, Bebidas, Ropa, Accesorios, Colmado, Otro; selección única en azul) → moneda (selector, DOP por defecto) → botón "Crear mi negocio" → nota "Podrás editarlo cuando quieras."
- **Decisión UX:** chips visuales en vez de dropdown: menos taps y enseña el lenguaje de categorías desde el inicio.
- **Validaciones:** nombre no vacío; tipo seleccionado.

### 04 · TÁTO Hoy (home)
- **Objetivo:** responder "¿cómo está mi negocio hoy?" en 5 segundos.
- **Jerarquía estricta:** saludo con fecha → tarjeta héroe azul "TÁTO notó esto" con el insight más urgente y acción "Ver producto" → semáforo de 3 métricas (Estables menta / Atención ámbar / En riesgo coral) → sección "Necesitan atención" con máximo 3 filas y "Ver todo".
- **Estados:** sin datos aún (invitación a agregar el primer producto); sin insights (tarjeta héroe en tinte azul claro con mensaje neutro).
- **Navegación:** tab Hoy activa.

### 05 · Inventario
- **Objetivo:** cada fila responde qué es, cuánto queda y en qué estado está, sin abrir el producto.
- **Estructura:** título con conteo de productos + botón azul de agregar → buscador → chips de filtro (Todos, categorías, y "Bajo stock" en ámbar como filtro de urgencia) → lista de filas de producto (tile con inicial y tinte de categoría, nombre, categoría, stock 15/700 y badge de estado).
- **Estados:** lista vacía (invitación con ilustración del símbolo), sin resultados de búsqueda, cargando (skeletons).
- **Navegación:** tab Inventario activa; tap en fila → Detalle (07); botón + → alta de producto / escáner.

### 06 · Escanear con IA
- **Objetivo:** clasificar un producto con la cámara; la IA sugiere, el usuario siempre confirma.
- **Estructura:** pantalla oscura (contexto cámara, tinta `#0F172A`) → título + cerrar → visor con esquinas menta como guía de encuadre y hint "Encuadra el producto" → hoja inferior blanca con: tile sparkles azul, "Sugerencia de TÁTO", categoría 17/700, badge de confianza (%) → botones Confirmar / Editar del mismo peso → microcopy "La IA sugiere, tú siempre confirmas."
- **Decisión UX:** Confirmar y Editar tienen igual jerarquía: refuerza que la IA no decide sola (argumento de IA honesta en la defensa).
- **Estados:** procesando (hoja con spinner), confianza baja (< 60%: se muestra "No estoy seguro" y las 8 categorías para elegir), permiso de cámara denegado (explicación + entrada manual).

### 07 · Detalle de producto
- **Objetivo:** estado, números e historial de un producto en una sola vista.
- **Estructura:** header con volver y editar → tile grande con inicial + nombre 19–20/700 + badges de categoría y estado → 3 métricas (Stock / Mínimo / "Se agota en ~X días" en tinte coral cuando aplica) → tarjeta de precios (Costo, Venta, Margen % en menta) → historial (fila por movimiento: círculo menta con flecha abajo para entradas, coral con flecha arriba para salidas, cantidad con signo) → botón "Registrar movimiento".
- **Decisión UX:** el dato inteligente ("se agota en ~3 días") es una métrica de primer nivel, no un texto escondido.

### 08 · Registrar movimiento
- **Objetivo:** la acción más frecuente de la app debe ser la más rápida.
- **Estructura:** header → control segmentado Entrada / Salida / Ajuste → selector de producto (fila con stock disponible visible) → stepper de cantidad gigante → hint en vivo "Quedarán X unidades" (tinte azul; coral si el valor no es válido) → motivo en chips (Venta, Merma, Regalo, Otro) → nota opcional → botón "Guardar salida" (el verbo cambia según el tipo).
- **Validaciones:** cantidad > 0; en salidas, cantidad ≤ stock disponible (el botón se deshabilita y el hint explica por qué); el hint previene el stock negativo antes de enviar.
- **Offline:** guardar funciona sin conexión; feedback "Guardado. Se sincronizará cuando haya internet."

### 09 · Insights
- **Objetivo:** decisiones, no gráficas decorativas.
- **Estructura:** título + período analizado → tarjeta héroe lila "Dinero inmovilizado" (RD$ en Display 28) → secciones como listas de decisión: "Por agotarse" (badge con ~días, coral/ámbar según urgencia), "Se mueven rápido" (badge menta con multiplicador ×N), "Sin movimiento" (badge neutro con días y RD$ parados en el detalle).
- **Regla de contenido:** cada fila dice el porqué en su detalle ("Quedan 6 · salen 2 al día") para que la recomendación sea explicable.
- **Estados:** datos insuficientes (< 7 días de movimientos: mensaje honesto de que TÁTO necesita más historial).
- **Navegación:** tab Insights activa; tap en fila → Detalle del producto.

### 10 · Perfil y configuración
- **Objetivo:** cuenta, negocio, sincronización y plan en un solo lugar.
- **Estructura:** título → avatar con iniciales + nombre + correo → tarjeta del negocio (nombre, tipo, moneda, acción Editar) → lista: Notificaciones (toggle), Sincronización (estado "Al día" en menta o "N pendientes" en ámbar), Plan Free con badge lila "Mejorar a Pro" (muestra el modelo de negocio en la demo), Cerrar sesión en coral → versión "TÁTO 1.0 · Hecho en República Dominicana".
- **Navegación:** tab Perfil activa.

---

## 7. Accesibilidad

- Contraste AA como mínimo en todo texto (los pares de tintes de la sección 2 cumplen).
- Área táctil mínima de 44 × 44 px en todo elemento interactivo.
- Texto mínimo 11 px; cuerpo 15 px.
- El color nunca es el único portador de significado: badges siempre con texto, íconos acompañados de label en navegación.
- Labels visibles en formularios (no solo placeholders).

---

## 8. Notas de implementación en Flutter

Referencia para llevar el sistema al código (coordinar antes de tocar `core/theme/`, que ya tiene una implementación base):

- Fuentes: paquete `google_fonts` → `GoogleFonts.spaceGrotesk` (titulares/números) y `GoogleFonts.inter` (resto), mapeadas en `TextTheme`.
- Colores: constantes en `core/theme` siguiendo la sección 2 (nombre sugerido: `TatoColors.azul`, `TatoColors.tinta`, `TatoColors.menta`, `TatoColors.lila`, `TatoColors.ambar`, `TatoColors.coral`, más los pares de tintes de estado).
- Radios y espaciado: constantes de la sección 4 para no hardcodear valores en widgets.
- Íconos: paquete `tabler_icons_next` o los Material Symbols equivalentes en outline.
- El ícono de app se genera desde `brand/tato_app_icon.svg` con `flutter_launcher_icons`.
