# Estructura de Carpetas - PingGo App

## 📁 Estructura General del Proyecto

```
ping_go/
├── 📱 Aplicación Flutter
│   ├── android/                 # Configuración Android
│   ├── ios/                     # Configuración iOS
│   ├── lib/                     # Código fuente Dart
│   ├── linux/                   # Configuración Linux
│   ├── macos/                   # Configuración macOS
│   ├── web/                     # Configuración Web
│   ├── windows/                 # Configuración Windows
│   └── test/                    # Tests
├── 🔧 Backend y Despliegue
│   ├── backend-deploy/          # Backend PHP
│   └── docs/                    # Documentación
├── 📋 Configuración
│   ├── pubspec.yaml            # Dependencias Flutter
│   ├── analysis_options.yaml   # Configuración análisis código
│   ├── devtools_options.yaml   # Configuración DevTools
│   └── nixpacks.toml           # Configuración despliegue
└── 📚 Documentación y Assets
    ├── assets/                 # Recursos estáticos
    ├── docs/                   # Documentación del proyecto
    └── README.md               # Documentación principal
```

## 🗂️ Estructura Detallada de `lib/`

```
lib/
├── main.dart                   # 🚀 Punto de entrada de la aplicación
└── src/
    ├── core/                   # 🔧 Núcleo de la aplicación
    │   ├── config/            # ⚙️ Configuraciones globales
    │   ├── services/          # 🔗 Servicios compartidos
    │   ├── utils/             # 🛠️ Utilidades comunes
    │   └── widgets/           # 🎨 Widgets base reutilizables
    ├── features/              # 📱 Características principales
    │   ├── auth/              # 🔐 Autenticación y registro
    │   │   ├── data/          # 💾 Capa de datos
    │   │   ├── domain/        # 🎯 Capa de dominio
    │   │   └── presentation/  # 📱 Capa de presentación
    │   ├── user/              # 👤 Funcionalidades de usuario
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/
    │   ├── conductor/         # 🚗 Funcionalidades de conductor
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/
    │   ├── admin/             # 👨‍💼 Panel de administración
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/
    │   └── onboarding/        # 🎯 Proceso de onboarding
    │       ├── data/
    │       ├── domain/
    │       └── presentation/
    ├── global/                 # 🌍 Configuraciones globales
    │   ├── config/            # ⚙️ Configuración de app
    │   ├── constants/         # 📊 Constantes globales
    │   ├── models/            # 📋 Modelos compartidos
    │   └── themes/            # 🎨 Temas y estilos
    ├── providers/             # 🔄 Proveedores de estado
    │   ├── database_provider.dart
    │   └── conductor_profile_provider.dart
    ├── routes/                # 🛣️ Configuración de navegación
    │   ├── app_router.dart    # 🧭 Router principal
    │   ├── route_names.dart   # 🏷️ Nombres de rutas
    │   └── animated_routes.dart # ✨ Rutas animadas
    └── widgets/               # 🧩 Widgets compartidos
        ├── auth/              # 🔐 Widgets de autenticación
        ├── common/            # 🔄 Widgets comunes
        ├── forms/             # 📝 Widgets de formularios
        └── ui/                # 🎨 Widgets de UI
```

## 📂 Estructura por Feature (Clean Architecture)

Cada feature sigue la estructura de Clean Architecture:

```
src/features/[feature_name]/
├── presentation/              # 📱 Capa de Presentación
│   ├── screens/              # 🖥️ Pantallas principales
│   │   ├── [screen_name]_screen.dart
│   │   └── [screen_name]_screen.dart
│   ├── widgets/              # 🧩 Widgets específicos del feature
│   │   ├── [widget_name]_widget.dart
│   │   └── [widget_name]_widget.dart
│   └── providers/            # 🔄 Providers específicos
│       └── [feature]_provider.dart
├── domain/                   # 🎯 Capa de Dominio
│   ├── entities/             # 📋 Entidades del dominio
│   │   └── [entity].dart
│   ├── repositories/         # 📚 Interfaces de repositorios
│   │   └── [feature]_repository.dart
│   └── usecases/             # ⚡ Casos de uso
│       └── [usecase].dart
└── data/                     # 💾 Capa de Datos
    ├── models/               # 📦 Modelos de datos
    │   └── [model].dart
    ├── repositories/         # 🗄️ Implementaciones de repositorios
    │   └── [feature]_repository_impl.dart
    └── datasources/          # 🔌 Fuentes de datos
        ├── [feature]_local_datasource.dart
        └── [feature]_remote_datasource.dart
```

## 🗃️ Estructura de `docs/`

```
docs/
├── INDEX.md                  # 📋 Índice principal de documentación
├── architecture/            # 🏗️ Documentación de arquitectura
│   ├── SYSTEM_ARCHITECTURE.md
│   ├── DESIGN_PATTERNS.md
│   └── FOLDER_STRUCTURE.md
├── user/                    # 👤 Documentación para usuarios
│   ├── USER_FEATURES.md
│   ├── REGISTRATION_FLOW.md
│   └── SERVICE_REQUESTS.md
├── conductor/               # 🚗 Documentación para conductores
│   ├── CONDUCTOR_FEATURES.md
│   ├── TRIP_MANAGEMENT.md
│   └── NAVIGATION_GUIDE.md
├── admin/                   # 👨‍💼 Documentación para administradores
│   ├── ADMIN_PANEL.md
│   ├── USER_MANAGEMENT.md
│   └── REPORTS_ANALYTICS.md
├── integrations/            # 🔗 Documentación de integraciones
│   ├── BACKEND_INTEGRATION.md
│   ├── MAP_SERVICES.md
│   └── EXTERNAL_APIS.md
├── testing/                 # 🧪 Guías de testing
│   ├── TESTING_GUIDE.md
│   ├── UNIT_TESTS.md
│   └── INTEGRATION_TESTS.md
├── deployment/              # 🚀 Documentación de despliegue
│   ├── DEPLOYMENT.md
│   ├── CID_PIPELINE.md
│   └── MONITORING.md
├── CONFIGURACION_ENTORNOS.md
├── GUIA_RAPIDA_ENTORNOS.md
├── SETUP_LARAGON.md
├── COMANDOS_UTILES.md
├── REQUERIMIENTOS_FUNCIONALES_NO_FUNCIONALES.md
├── RESUMEN_CAMBIOS_LOCAL.md
├── MEJORAS_UI_REGISTRO.md
├── SISTEMA_PRECIOS_DOBLE_PANTALLA.md
├── glossary/                # 📖 Glosario de términos
│   └── GLOSSARY.md
└── troubleshooting/         # 🔧 Solución de problemas
    └── TROUBLESHOOTING.md
```

## 📦 Estructura de `backend-deploy/`

```
backend-deploy/
├── 📋 Documentación
│   ├── README.md
│   └── docs/
├── 🔧 Configuración
│   ├── composer.json        # 📦 Dependencias PHP
│   ├── nixpacks.toml       # 🚀 Configuración despliegue
│   ├── railway.json        # 🚂 Configuración Railway
│   └── render.yaml         # 🎨 Configuración Render
├── 🌐 API Endpoints
│   ├── index.php           # 🚀 Punto de entrada API
│   └── health.php          # 💚 Endpoint de salud
├── 🔐 Autenticación
│   ├── auth/
│   │   ├── login.php
│   │   ├── register.php
│   │   └── verify.php
├── 👤 Usuarios
│   └── user/
│       ├── profile.php
│       └── trips.php
├── 🚗 Conductores
│   └── conductor/
│       ├── profile.php
│       └── trips.php
├── 👨‍💼 Administración
│   └── admin/
│       ├── users.php
│       ├── statistics.php
│       └── audit.php
├── ⚙️ Configuración
│   └── config/
│       ├── database.php
│       └── cors.php
├── 📊 Base de datos
│   └── database/
│       ├── connection.php
│       └── queries.php
├── 📝 Logs y Auditoría
│   └── logs/
├── 📎 Uploads
│   └── uploads/
├── 🧪 Tests
│   └── tests/
└── 📚 Librerías
    └── vendor/              # 📦 Dependencias instaladas
```

## 🎨 Estructura de `assets/`

```
assets/
├── images/                  # 🖼️ Imágenes de la aplicación
│   ├── logo.png            # 🏷️ Logo principal
│   ├── background.jpg      # 🌅 Imagen de fondo
│   ├── icons/              # 🎯 Iconos específicos
│   │   ├── user.png
│   │   ├── car.png
│   │   └── admin.png
│   └── placeholders/       # 📷 Imágenes placeholder
│       ├── avatar.png
│       └── trip.png
├── sounds/                  # 🔊 Efectos de sonido
│   ├── notification.mp3
│   └── success.mp3
└── fonts/                   # ✍️ Fuentes personalizadas (si las hay)
    └── custom_font.ttf
```

## 🔧 Estructura de Configuración

### Flutter (`pubspec.yaml`)
```yaml
name: ping_go
description: "Ping-Go - App de Transporte"
version: 0.1.0

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  # ... dependencias principales

dev_dependencies:
  flutter_test:
    sdk: flutter
  # ... dependencias de desarrollo

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

### Análisis de Código (`analysis_options.yaml`)
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false

linter:
  rules:
    - always_declare_return_types
    - prefer_const_constructors
    - prefer_const_declarations
    # ... más reglas
```

## 📋 Convenciones de Nomenclatura

### Archivos y Carpetas
- **snake_case**: Para nombres de archivos (`user_profile_screen.dart`)
- **PascalCase**: Para nombres de clases (`UserProfileScreen`)
- **camelCase**: Para variables y métodos (`getUserProfile()`)

### Estructura de Features
- **auth**: Autenticación y registro
- **user**: Funcionalidades del usuario final
- **conductor**: Funcionalidades del conductor
- **admin**: Panel de administración
- **onboarding**: Proceso de bienvenida

### Prefijos de Archivos
- `_screen.dart`: Pantallas principales
- `_widget.dart`: Widgets reutilizables
- `_provider.dart`: Proveedores de estado
- `_repository.dart`: Interfaces de repositorios
- `_repository_impl.dart`: Implementaciones de repositorios
- `_datasource.dart`: Fuentes de datos
- `_model.dart`: Modelos de datos
- `_entity.dart`: Entidades de dominio

## 🔍 Navegación por la Estructura

### Desde el Punto de Entrada
1. `main.dart` → Configura providers y inicializa app
2. `AppRouter` → Gestiona navegación entre pantallas
3. `AuthWrapper` → Determina pantalla inicial basada en autenticación
4. Features → Implementan funcionalidades específicas

### Flujo de Datos Típico
1. **UI** (`screens/`) → Interactúa con usuario
2. **Provider** (`providers/`) → Gestiona estado
3. **Use Case** (`usecases/`) → Contiene lógica de negocio
4. **Repository** (`repositories/`) → Abstrae acceso a datos
5. **Data Source** (`datasources/`) → Accede a APIs/DB

## 📊 Estadísticas de la Estructura

### Distribución de Código por Capa
- **Presentation**: ~40% (UI, navegación, estado)
- **Domain**: ~20% (lógica de negocio, entidades)
- **Data**: ~30% (modelos, repositorios, APIs)
- **Core**: ~10% (utilidades, configuración)

### Número de Features
- **4 features principales**: auth, user, conductor, admin
- **1 feature auxiliar**: onboarding
- **Total**: 5 features

### Cobertura de Plataformas
- **Móviles**: Android, iOS
- **Desktop**: Windows, macOS, Linux
- **Web**: Navegadores modernos

Esta estructura garantiza mantenibilidad, escalabilidad y facilidad de testing, siguiendo las mejores prácticas de desarrollo Flutter y Clean Architecture.

---

*Última actualización: $(date '+%Y-%m-%d')*