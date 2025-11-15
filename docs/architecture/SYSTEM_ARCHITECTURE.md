# Arquitectura del Sistema - PingGo App

## 📋 Información General

**PingGo** es una aplicación móvil de transporte desarrollada en Flutter que conecta usuarios, conductores y administradores en una plataforma integral de servicios de movilidad.

### 🎯 Propósito
La aplicación permite a los usuarios solicitar servicios de transporte, a los conductores gestionar sus viajes y a los administradores supervisar todas las operaciones del sistema.

## 🏗️ Arquitectura General

### Patrón Arquitectónico
La aplicación sigue el patrón de **Clean Architecture** combinado con **Provider** para el manejo de estado, estructurando el código en las siguientes capas:

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── src/
│   ├── core/                 # Núcleo de la aplicación (servicios compartidos)
│   ├── features/             # Características principales por dominio
│   ├── global/               # Configuraciones globales
│   ├── providers/            # Proveedores de estado (Provider pattern)
│   ├── routes/               # Configuración de navegación
│   └── widgets/              # Componentes reutilizables de UI
```

### Capas de la Arquitectura

#### 1. **Presentation Layer** (Capa de Presentación)
- **Ubicación**: `src/features/*/presentation/`
- **Responsabilidades**:
  - Widgets de UI y pantallas
  - Manejo de estado de la interfaz
  - Navegación entre pantallas
- **Tecnologías**: Flutter Widgets, Provider

#### 2. **Domain Layer** (Capa de Dominio)
- **Ubicación**: `src/features/*/domain/`
- **Responsabilidades**:
  - Lógica de negocio
  - Entidades del dominio
  - Casos de uso (Use Cases)
- **Tecnologías**: Dart puro

#### 3. **Data Layer** (Capa de Datos)
- **Ubicación**: `src/features/*/data/`
- **Responsabilidades**:
  - Repositorios
  - Data Sources (API, Base de datos local)
  - Modelos de datos
- **Tecnologías**: HTTP, SQLite/MySQL, SharedPreferences

#### 4. **Core Layer** (Capa Núcleo)
- **Ubicación**: `src/core/`
- **Responsabilidades**:
  - Servicios compartidos
  - Utilidades comunes
  - Configuraciones globales
- **Tecnologías**: Dart

## 🔧 Tecnologías Principales

### Framework y Lenguaje
- **Flutter**: Framework de desarrollo móvil multiplataforma
- **Dart**: Lenguaje de programación (SDK >= 3.8.0)
- **Versión**: 0.1.0

### Manejo de Estado
- **Provider**: Patrón principal para inyección de dependencias y manejo de estado
- **ChangeNotifier**: Para notificación de cambios en el estado

### Base de Datos y Almacenamiento
- **MySQL**: Base de datos principal (mysql1: ^0.20.0)
- **SharedPreferences**: Almacenamiento local de preferencias
- **SQLite**: Base de datos local (a través de sqflite)

### Servicios Externos
- **HTTP**: Cliente para comunicación con APIs (http: ^1.1.0)
- **Geolocalización**: geolocator (^14.0.2) y geocoding (^4.0.0)
- **Mapas**: flutter_map (^8.2.2) con latlong2 (^0.9.1)

### UI y UX
- **Material Design**: Framework de diseño de Google
- **Shimmer**: Efectos de carga (shimmer: ^3.0.0)
- **Font Awesome**: Iconos (font_awesome_flutter: ^10.7.0)
- **Charts**: Gráficos y visualizaciones (fl_chart: ^1.1.1)

### Utilidades
- **UUID**: Generación de identificadores únicos (uuid: ^4.2.1)
- **Crypto**: Funciones criptográficas (crypto: ^3.0.3)
- **Image Picker**: Selección de imágenes (image_picker: ^1.0.7)
- **File Picker**: Selección de archivos (file_picker: ^10.3.3)
- **Permission Handler**: Gestión de permisos (permission_handler: ^12.0.1)
- **Path Provider**: Gestión de rutas del sistema (path_provider: ^2.1.3)
- **Audioplayers**: Reproducción de audio (audioplayers: ^6.1.0)

## 📱 Características por Módulo

### 👤 Módulo de Usuario
- **Autenticación**: Login, registro, verificación de email
- **Solicitudes de Servicio**: Selección de destino, métodos de pago
- **Perfil**: Gestión de perfil de usuario
- **Historial**: Historial de viajes
- **Pagos**: Gestión de métodos de pago

### 🚗 Módulo de Conductor
- **Perfil de Conductor**: Gestión del perfil profesional
- **Gestión de Viajes**: Aceptar, gestionar y completar viajes
- **Navegación**: Integración con mapas y GPS
- **Documentación**: Gestión de documentos requeridos

### 👨‍💼 Módulo de Administrador
- **Panel de Control**: Dashboard administrativo
- **Gestión de Usuarios**: Administración de usuarios y conductores
- **Estadísticas**: Reportes y análisis de datos
- **Auditoría**: Logs de auditoría del sistema

### 🔐 Módulo de Autenticación
- **Login/Register**: Flujos de autenticación múltiple
- **Verificación**: Verificación por email y teléfono
- **Onboarding**: Proceso de bienvenida para nuevos usuarios
- **Recuperación**: Recuperación de contraseña

## 🗂️ Estructura de Features

Cada feature sigue la estructura de Clean Architecture:

```
src/features/[feature_name]/
├── presentation/
│   ├── screens/           # Pantallas de UI
│   ├── widgets/           # Widgets específicos del feature
│   └── providers/         # Providers específicos
├── domain/
│   ├── entities/          # Entidades del dominio
│   ├── repositories/      # Interfaces de repositorios
│   └── usecases/          # Casos de uso
└── data/
    ├── models/            # Modelos de datos
    ├── repositories/      # Implementaciones de repositorios
    └── datasources/       # Fuentes de datos (API, DB)
```

## 🔄 Flujo de Datos

### Patrón de Comunicación
1. **UI** → **Provider** → **Use Case** → **Repository** → **Data Source**
2. **Data Source** → **Repository** → **Use Case** → **Provider** → **UI**

### Inyección de Dependencias
- **Service Locator**: Configurado en `main.dart`
- **MultiProvider**: Proveedores principales de la aplicación
- **Provider.of()**: Acceso a proveedores en widgets

## 🎨 Tema y Diseño

### Paleta de Colores
- **Primary**: Yellow (Colors.yellow)
- **Background**: Black (Colors.black)
- **Surface**: Negro con transparencias para efectos glassmorphism

### Tema Global
```dart
ThemeData(
  primarySwatch: Colors.yellow,
  visualDensity: VisualDensity.standard,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
  ),
)
```

## 🚀 Navegación y Rutas

### Sistema de Rutas
- **AppRouter**: Router principal con rutas nombradas
- **RouteNames**: Constantes para nombres de rutas
- **Animated Routes**: Transiciones animadas entre pantallas

### Tipos de Rutas
- **MaterialPageRoute**: Rutas estándar
- **FadeSlidePageRoute**: Rutas con animaciones personalizadas

## 🔍 Monitoreo y Logging

### Route Logger
- Observador de navegación para debugging
- Registra cambios de ruta en modo debug
- Métodos: `didPush`, `didPop`, `didReplace`

## 📊 Escalabilidad y Mantenimiento

### Separación de Responsabilidades
- Cada feature es independiente
- Interfaces claras entre capas
- Fácil testing unitario

### Extensibilidad
- Nuevo features siguiendo la estructura establecida
- Providers adicionales para nuevo estado
- Nuevas rutas en AppRouter

### Mantenibilidad
- Código bien documentado en español
- Comentarios descriptivos en todas las funciones
- Estructura clara y consistente

---

*Última actualización: $(date '+%Y-%m-%d')*