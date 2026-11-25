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
| Proyecto Flutter (Android + Web) | ⏳ Pendiente | Falta `pubspec.yaml` y las carpetas `android/` y `web/` |
| Capa `domain` (entidades, contratos, casos de uso) | ⏳ En curso | Responsable: Domain Architect |
| Capa `data` (datasources, models, repositories) | ⏳ En curso | Responsable: Backend & Data Engineer |
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
| 🔌 API REST | `https://<tu-api>.onrender.com/api/v1` | ⏳ Pendiente |
| 🩺 Health check API | `https://<tu-api>.onrender.com/health` | ⏳ Pendiente |
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
| Inyección de dependencias | `get_it` | Registro de datasources, repositorios y casos de uso |
| Cliente HTTP | `dio` | Consumo de la API REST |
| Formato de fechas | `intl` | Localización `es_CO` y formateo de fecha/hora |
| Backend | REST (PostgREST o FastAPI) | Exposición segura de la base de datos |
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
| `core` | Constantes, errores, cliente HTTP, utilidades | Puede ser usado por cualquier capa |
| `domain` | Entidades, contratos de repositorio y casos de uso | **No** importa `data` ni `presentation` ni paquetes de UI |
| `data` | Models, datasources y repositorios | Implementa los contratos de `domain` |
| `presentation` | Bloc, pages y widgets | Consume casos de uso a través de `get_it` |

**Flujo de una acción (ejemplo: crear evento):**
`FormPage` → `PlannerBloc` → `CrearEventoUseCase` → `PlannerRepository` (contrato)
→ `PlannerRepositoryImpl` → `PlannerRemoteDataSource` → API REST → Neon.

---

## 🗄️ Modelo de datos (Neon · PostgreSQL)

Esquema base desplegado por el Tech Lead / DevOps. Extensión requerida:
`pgcrypto` (para `gen_random_uuid()`).

### Tabla `categorias`

| Columna | Tipo | Restricciones |
| --- | --- | --- |
| `id` | `uuid` | PK, `DEFAULT gen_random_uuid()` |
| `nombre` | `varchar(60)` | `NOT NULL`, `UNIQUE` |
| `color` | `varchar(9)` | `NOT NULL`, `DEFAULT '#3F51B5'` |
| `created_at` | `timestamptz` | `NOT NULL`, `DEFAULT now()` |

### Tabla `eventos`

| Columna | Tipo | Restricciones |
| --- | --- | --- |
| `id` | `uuid` | PK, `DEFAULT gen_random_uuid()` |
| `titulo` | `varchar(120)` | `NOT NULL` |
| `descripcion` | `text` | Nulo permitido |
| `fecha_inicio` | `timestamptz` | `NOT NULL` |
| `fecha_fin` | `timestamptz` | `NOT NULL`, `CHECK (fecha_fin >= fecha_inicio)` |
| `todo_el_dia` | `boolean` | `NOT NULL`, `DEFAULT false` |
| `recordatorio_minutos` | `integer` | Nulo permitido, `CHECK (>= 0)` |
| `categoria_id` | `uuid` | FK → `categorias(id)` `ON DELETE SET NULL` |
| `created_at` | `timestamptz` | `NOT NULL`, `DEFAULT now()` |
| `updated_at` | `timestamptz` | `NOT NULL`, `DEFAULT now()` |

Índices sugeridos: `eventos(fecha_inicio)`, `eventos(categoria_id)` y
`categorias(nombre)`.

---

## 🔌 Contrato de la API REST

Base: `/api/v1`. Respuestas en JSON y errores con formato
`{ "message": "...", "code": "..." }`.

| Método | Endpoint | Descripción | Cuerpo principal |
| --- | --- | --- | --- |
| `GET` | `/eventos` | Lista eventos (filtros `desde`, `hasta`, `categoria_id`) | — |
| `GET` | `/eventos/{id}` | Obtiene un evento por id | — |
| `POST` | `/eventos` | Crea un evento | `titulo`, `descripcion`, `fecha_inicio`, `fecha_fin`, `todo_el_dia`, `categoria_id` |
| `PUT` | `/eventos/{id}` | Actualiza un evento | Campos editables |
| `DELETE` | `/eventos/{id}` | Elimina un evento | — |
| `GET` | `/categorias` | Lista categorías | — |
| `POST` | `/categorias` | Crea una categoría | `nombre`, `color` |

Códigos: `200` consulta/actualización, `201` creación, `204` eliminación,
`400` validación, `404` no encontrado, `500` error del servidor.

| Endpoint | Caso de uso (`domain/usecases`) |
| --- | --- |
| `POST /eventos` | `CrearEvento` |
| `GET /eventos` | `ListarEventos` |
| `PUT /eventos/{id}` | `ActualizarEvento` |
| `DELETE /eventos/{id}` | `EliminarEvento` |

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

### Configuración de la URL de la API

La URL vive en `lib/core/constants/` y puede sobreescribirse en compilación:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://<tu-api>.onrender.com/api/v1
```

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

- La cadena de conexión de Neon **nunca** se incluye en el repositorio ni en el cliente Flutter; se usa como variable de entorno del backend.
- Configura `Row Level Security` si se expone Neon vía PostgREST, o valida los datos en FastAPI.
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
