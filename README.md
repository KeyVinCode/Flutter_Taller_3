# 📅 Planner — Gestor de Agenda

Aplicación móvil y web desarrollada en **Flutter** bajo **Clean Architecture**, con
persistencia en **Neon (PostgreSQL Serverless)** y trabajo colaborativo mediante
**GitFlow** para un equipo de 5 aprendices.

> **Taller 3 — Flutter “Gestor de Agenda”**
> Programa de formación SENA · Actividad 8

---

## 📌 Descripción

**Planner** permite gestionar una agenda personal y compartida: crear, editar,
listar y eliminar eventos, clasificarlos por categorías y consultarlos en un
calendario interactivo. La aplicación se ejecuta en **Android** y **Web**
(las únicas plataformas habilitadas para el taller).

Alcance funcional:

- Crear, actualizar y eliminar eventos (título, descripción, fecha/hora, categoría, recordatorio).
- Visualizar los eventos en un calendario mensual y en un listado.
- Organizar los eventos por categorías con color identificador.
- Sincronizar la información con la base de datos en Neon a través de una API REST.

---

## 🚦 Estado del proyecto

| Componente | Estado | Observaciones |
| --- | --- | --- |
| Estructura Clean Architecture (`lib/`) | ✅ Lista | Encarpetado completo del taller, con `.gitkeep` en carpetas vacías |
| Proyecto Flutter (Android + Web) | ✅ Listo | Proyecto y targets Android/Web creados |
| Capa `domain` (entidades, contratos, casos de uso) | ⏳ En curso | Responsable: Domain Architect |
| Puente PostgREST (cliente, datasource y models) | ✅ Implementado | Usa JWT externo; falta configurar/desplegar la API y sus permisos |
| Capa `presentation` (bloc, pages, widgets) | ⏳ En curso | Responsables: UI/UX y State & Integration Dev |
| Esquema SQL en Neon | ⏳ Pendiente | Responsable: Tech Lead / DevOps |
| API REST desplegada | ⏳ Pendiente | — |
| Build Web desplegada | ⏳ Pendiente | — |

---

## 🔗 Enlaces de despliegue

<!-- Reemplaza cada valor entre <> cuando el despliegue esté disponible -->

| Recurso | URL | Estado |
| --- | --- | --- |
| 🌐 Web (Flutter Web) | `https://<tu-app>.web.app` | ⏳ Pendiente |
| 🔌 Neon Data API / PostgREST | `https://<endpoint-postgrest>` | ⏳ Pendiente |
| 🗄️ Consola Neon | `https://console.neon.tech/app/projects/<project-id>` | ⏳ Pendiente |
| 📦 Repositorio | `https://github.com/<organizacion>/<repositorio>` | ⏳ Pendiente |

---

## 👥 Equipo y ramas asignadas

| Rol | Aprendiz | Rama | Responsabilidad técnica |
| --- | --- | --- | --- |
| 1. Tech Lead / DevOps | `Kevin D. Patiño` | `develop` y `release/*` | Configuración del repo, protección de ramas, revisión de PR y despliegue del esquema SQL en Neon |
| 2. Backend & Data Engineer | `Camila Tobon` | `feature/neon-datasource` | Tablas en Neon, API REST (PostgREST/FastAPI), `data/datasources` y `data/models` |
| 3. Domain Architect | `Yilma López` | `feature/domain-layer` | Entidades `Evento` y `Categoria`, contratos de repositorio y casos de uso |
| 4. UI/UX & Core Widgets | `Sebastian Taborda` | `feature/ui-components` | `ThemeData`, widgets reutilizables, calendario interactivo y tarjetas de eventos |
| 5. State & Integration Dev | `Valery Vergara` | `feature/presentation-logic` | Bloc/Provider, pantallas (`pages/`) e inyección de dependencias con `get_it` |

---

## 🧰 Stack tecnológico

| Capa / Área | Tecnología | Uso |
| --- | --- | --- |
| Framework | Flutter `>= 3.24` (Dart `>= 3.5`) | UI multiplataforma (Android y Web) |
| Gestión de estado | `flutter_bloc` + `equatable` | Eventos y estados inmutables |
| Inyección de dependencias | Pendiente | Registrar datasources, repositorios y casos de uso al integrar `domain` |
| Cliente HTTP | `http` | Consumo de PostgREST |
| Formato de fechas | `intl` | Localización `es_CO` y formateo de fecha/hora |
| Backend | Neon Data API (PostgREST) | Acceso REST a PostgreSQL con JWT y RLS |
| Base de datos | Neon · PostgreSQL Serverless | Persistencia de eventos y categorías |

> Ninguna credencial de Neon se almacena en el cliente: la app solo conoce la URL
> pública de la API (`ApiConstants.baseUrl`).

---

## 🏗️ Arquitectura — Clean Architecture

El proyecto se organiza en tres capas con dependencias unidireccionales:
`presentation → domain ← data`. El dominio no conoce Flutter ni la base de datos.

```
lib/
├── core/
│   ├── constants/        # URLs de API, claves, rutas
│   ├── errors/           # Manejo de excepciones y Failures
│   ├── network/          # Cliente HTTP (Dio/Http) y estado de red
│   └── utils/            # Formateadores de fecha, validadores
├── features/
│   └── planner/
│       ├── data/
│       │   ├── datasources/   # Conexión remota (API/Neon) y local (caché)
│       │   ├── models/        # Mapeo JSON <-> Entidad (fromJson / toJson)
│       │   └── repositories/  # Implementación de los contratos de dominio
│       ├── domain/
│       │   ├── entities/      # Objetos de negocio puros (Evento, Categoria)
│       │   ├── repositories/  # Interfaces / Contratos abstractos
│       │   └── usecases/      # Casos de uso (CrearEvento, ListarEventos, etc.)
│       └── presentation/
│           ├── bloc/          # Gestión de estado (Bloc)
│           ├── pages/         # Pantallas completas (HomePage, FormPage)
│           └── widgets/       # Componentes reutilizables (EventCard, CustomInput)
└── main.dart
```

| Capa | Contenido | Regla de dependencia |
| --- | --- | --- |
| `core` | Configuración, errores, cliente HTTP, utilidades | Puede ser usado por cualquier capa |
| `domain` | Entidades, contratos de repositorio y casos de uso | **No** importa `data` ni `presentation` ni paquetes de UI |
| `data` | Models, datasources y repositorios | Implementa los contratos de `domain` |
| `presentation` | Bloc, pages y widgets | Consume casos de uso a través de `get_it` |

**Flujo de una acción (ejemplo: crear evento):**
`FormPage` → `PlannerBloc` → caso de uso → `AgendaRepository` (contrato)
→ `AgendaRepositoryImpl` → `PlannerRemoteDataSource` → API REST → Neon.

`EventoModel` serializa el esquema SQL con `fromJson`/`toJson` y payloads separados para
inserción y actualización. El repositorio conserva los errores PostgREST y los clasifica como
errores de red, autenticación, SQLSTATE, API o formato para que presentación pueda manejarlos.

---

## 🗄️ Modelo de datos (Neon · PostgreSQL)

El puente Flutter se alinea con el esquema actual de [`database/schema.sql`](database/schema.sql).
Los identificadores son `BIGINT`, las fechas son `TIMESTAMP` y las tablas pertenecen a cada
usuario mediante `usuario_id`.

### Tabla `usuarios`

| Columna | Tipo | Restricciones |
| --- | --- | --- |
| `id` | `bigint` | PK, identity |
| `nombre` | `varchar(100)` | `NOT NULL` |
| `email` | `varchar(150)` | `NOT NULL`, `UNIQUE` |
| `password_hash` | `text` | `NOT NULL` |
| `created_at` | `timestamp` | `NOT NULL`, `DEFAULT now()` |

El cliente Flutter no consulta ni administra `usuarios`/`password_hash`. La autenticación debe
ser responsabilidad de un proveedor confiable que emita JWT; no implementes login comparando
contraseñas desde la app.

### Tabla `categorias`

| Columna | Tipo | Restricciones |
| --- | --- | --- |
| `id` | `bigint` | PK, identity |
| `usuario_id` | `bigint` | FK → `usuarios(id)`, `ON DELETE CASCADE` |
| `nombre` | `varchar(80)` | `NOT NULL` |
| `color_hex` | `char(7)` | `NOT NULL`, `DEFAULT '#2196F3'` |
| `created_at` | `timestamp` | `NOT NULL`, `DEFAULT now()` |

### Tabla `eventos`

| Columna | Tipo | Restricciones |
| --- | --- | --- |
| `id` | `bigint` | PK, identity |
| `usuario_id` | `bigint` | FK → `usuarios(id)`, `ON DELETE CASCADE` |
| `categoria_id` | `bigint` | FK → `categorias(id)`, `ON DELETE SET NULL` |
| `titulo` | `varchar(150)` | `NOT NULL` |
| `descripcion` | `text` | Nulo permitido |
| `ubicacion` | `varchar(200)` | Nulo permitido |
| `fecha_inicio`, `fecha_fin` | `timestamp` | `NOT NULL`, `fecha_fin >= fecha_inicio` |
| `created_at`, `updated_at` | `timestamp` | `NOT NULL`, `DEFAULT now()` |

El esquema actual no incluye `todo_el_dia` ni recordatorios. Las fechas se envían en UTC
(ISO 8601) y se convierten al tipo `timestamp` de PostgreSQL.

---

## 🔌 Puente Flutter → Neon Data API / PostgREST

`PlannerRemoteDataSource` consulta las tablas `eventos` y `categorias` de PostgREST. La URL
configurada debe ser la raíz de la API PostgREST de Neon e incluir el prefijo/versionado que
indique la consola de Neon. La capa envía un JWT como `Authorization: Bearer ...`; el token lo
provee el servicio de autenticación de la aplicación, nunca se guarda en el código ni en
parámetros de compilación.

| Operación | Recurso PostgREST | Comportamiento |
| --- | --- | --- |
| Listar eventos | `GET /eventos` | Filtra por usuario; opcionalmente por fechas y categoría |
| Crear evento | `POST /eventos` | Envía las columnas del esquema y recibe la fila creada |
| Actualizar evento | `PATCH /eventos?id=eq.<id>&usuario_id=eq.<usuario>` | Actualiza campos y `updated_at` |
| Eliminar evento | `DELETE /eventos?id=eq.<id>&usuario_id=eq.<usuario>` | Elimina el evento del usuario |
| Listar categorías | `GET /categorias` | Filtra por usuario |
| Crear categoría | `POST /categorias` | Envía `usuario_id`, `nombre` y `color_hex` |

### Configurar y usar

```bash
flutter run -d chrome --dart-define=NEON_DATA_API_URL=https://<endpoint-postgrest>
flutter run -d android --dart-define=NEON_DATA_API_URL=https://<endpoint-postgrest>
```

`NeonDataApiConfig.fromEnvironment()` lee esa URL. Al integrar el proveedor de autenticación,
inyecta su función de token en `PostgrestClient` y registra el datasource en el punto de
inyección de dependencias:

```dart
final client = PostgrestClient(
  config: NeonDataApiConfig.fromEnvironment(),
  accessTokenProvider: authSession.getAccessToken,
);
final plannerDataSource = PlannerRemoteDataSource(client: client);
```

El datasource ofrece `listarEventos`, `crearEvento`, `actualizarEvento`, `eliminarEvento`,
`listarCategorias` y `crearCategoria`. Las respuestas de PostgREST se validan y sus errores
se propagan con código y detalles; una respuesta sin JWT se rechaza antes de hacer la petición.

---

## 🚀 Puesta en marcha

### Requisitos previos

- Flutter SDK `>= 3.24` con Dart `>= 3.5` (`flutter doctor` sin errores críticos).
- Android Studio / SDK de Android para emulador o dispositivo.
- Chrome para el target web.
- Acceso al repositorio y a la base de datos en Neon.

### Creación del proyecto (solo Android y Web)

```bash
flutter create --platforms=android,web --org com.sena.planner .
flutter pub get
```

### Ejecución

```bash
flutter run -d chrome      # Web
flutter run -d android     # Android

flutter build web --release
flutter build apk --release
```

La URL de Neon Data API se configura mediante `--dart-define=NEON_DATA_API_URL=...`, como se
describe en la sección del puente PostgREST. La URL es pública; no pases secretos ni tokens con
`--dart-define`.

---

## 🌿 GitFlow obligatorio

### Ramas

| Rama | Propósito | Origen | Destino del merge |
| --- | --- | --- | --- |
| `main` | Código en producción, etiquetado | — | — |
| `develop` | Integración continua del equipo | `main` | `release/*` |
| `feature/<nombre-tarea>` | Una funcionalidad por rama | `develop` | `develop` (vía PR) |
| `release/vX.0` | Pruebas de integración previas al despliegue | `develop` | `main` y `develop` |

### Reglas del equipo

1. **Prohibido** hacer `push` directo a `main` o `develop` (ramas protegidas en GitHub).
2. Toda funcionalidad nace de `develop`: `feature/nombre-tarea` en `kebab-case`.
3. Para integrar a `develop` se requiere **Pull Request aprobado por al menos 2 compañeros**, incluido el Tech Lead.
4. Al cerrar una fase se crea `release/vX.0`; tras validar se fusiona a `main` y se etiqueta (`git tag v1.0.0`).
5. Cada PR debe compilar (`flutter analyze` sin errores) y describir el cambio y cómo probarlo.

### Ramas del taller

`feature/neon-datasource` · `feature/domain-layer` · `feature/ui-components` ·
`feature/presentation-logic`

### Flujo resumido

```bash
git checkout develop
git pull origin develop
git checkout -b feature/nombre-tarea
# ... desarrollo ...
git push -u origin feature/nombre-tarea   # abrir PR hacia develop

# Cierre de fase
git checkout -b release/v1.0 develop
git checkout main
git merge --no-ff release/v1.0
git tag -a v1.0.0 -m "Primera versión estable"
git push origin main --tags
```

---

## 📝 Convenciones de código

- **Archivos y carpetas:** `snake_case` (`evento_form_page.dart`, `planner_bloc.dart`).
- **Clases:** `PascalCase` (`Evento`, `CategoriaModel`, `CrearEvento`).
- **Variables y métodos:** `camelCase`.
- **Sufijos por capa:** `Model` (data), nombre de acción (domain), `Bloc`/`Event`/`State` (presentation).
- **Commits (Conventional Commits):** `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- **Idioma:** dominio y UI en español; infraestructura (`Model`, `DataSource`, `Repository`) en inglés.

---

## ✅ Lista de verificación de entrega

- [ ] Proyecto Flutter creado únicamente con plataformas `android` y `web`.
- [ ] Estructura de carpetas idéntica al encarpetado del taller.
- [ ] Entidades `Evento` y `Categoria` sin dependencias de Flutter ni de la base de datos.
- [ ] Contrato `PlannerRepository` en `domain/repositories` e implementación en `data/repositories`.
- [ ] Casos de uso `CrearEvento`, `ListarEventos`, `ActualizarEvento`, `EliminarEvento`.
- [ ] `models` con `fromJson` / `toJson`.
- [ ] Inyección de dependencias con `get_it` registrada en un único punto.
- [ ] `ThemeData` propio, calendario interactivo y tarjetas de eventos.
- [ ] Esquema SQL creado en Neon y API REST desplegada.
- [ ] Build web publicada y APK generado.
- [ ] `README.md` actualizado con los enlaces reales de API y Web.
- [ ] Ramas `main`, `develop`, `release/v1.0` y tag `v1.0.0` creados; PRs aprobados por 2 compañeros.

---

## 🔐 Notas de seguridad

- La cadena de conexión de Neon y las credenciales de base de datos **nunca** se incluyen en el
  repositorio ni en Flutter. `NEON_DATA_API_URL` es solo la URL pública del endpoint; no es una
  credencial.
- Antes de exponer las tablas, habilita RLS y concede acceso solo al rol autenticado. Las
  políticas deben vincular `usuario_id` con un claim del JWT firmado por un proveedor confiable.
  Los filtros por usuario del cliente son conveniencia, no control de acceso.
- No uses una clave `service_role`, contraseña de base de datos ni JWT privilegiado en la app.
- Habilita CORS únicamente para el dominio de la app web.
- No subir `*.env`, `key.properties`, `google-services.json` ni archivos de firma (ver `.gitignore`).

---

## 🛠️ Scripts auxiliares

En la raíz del repositorio se incluyen dos scripts que regeneran el encarpetado.
Deben ejecutarse solo sobre un proyecto vacío: no sobrescriben archivos existentes.

| Script | Entorno | Comando |
| --- | --- | --- |
| `create_structure.sh` | Git Bash / WSL / Linux | `bash create_structure.sh` |
| `create_structure.ps1` | Windows (PowerShell) | `powershell -ExecutionPolicy Bypass -File .\create_structure.ps1` |

Opciones: `[ruta]` / `-BaseDir <ruta>` y `--no-gitkeep` / `-NoGitKeep`.

---

## 📄 Licencia

Proyecto académico desarrollado con fines formativos en el **SENA**. Uso
educativo; no se autoriza su explotación comercial sin permiso del equipo autor.
