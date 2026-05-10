---
name: skill
description: >
  Contexto completo del proyecto PingGo - App de transporte tipo Uber/Didi/InDrive.
  Incluye arquitectura Flutter + PHP backend, convenciones de codigo, sistema de colores,
  patrones de diseno, despliegue SSH, migraciones de BD, y reglas para agentes IA.
  Usar esta skill SIEMPRE antes de modificar cualquier archivo del proyecto.
---

# PingGo - Skill de Contexto Completo del Proyecto

> **Idioma de documentacion y comentarios: ESPANOL**
> Todo comentario en el codigo, documentacion en `docs/`, y mensajes al usuario deben
> estar escritos en espanol. Los nombres de clases/variables siguen convenciones Dart/PHP.

---

## 1. Descripcion General del Proyecto

**PingGo** es una aplicacion movil de transporte (tipo Uber, Didi, InDrive) desarrollada con:

- **Frontend**: Flutter (Dart) SDK >=3.8.0
- **Backend**: PHP puro con API REST (sin framework)
- **Base de Datos**: MySQL (PDO)
- **Servidor de Produccion**: VPS Linux accesible via `ssh root@2.24.223.16`

La app tiene **3 roles principales**:
1. **Usuario (Pasajero)**: Solicita viajes, califica conductores
2. **Conductor**: Acepta/rechaza viajes, gestiona documentos y comisiones
3. **Administrador**: Aprueba conductores, gestiona el sistema

---

## 2. Arquitectura del Proyecto

### 2.1 Arquitectura Flutter (Frontend)

Se sigue **Clean Architecture** con la siguiente estructura:

```
lib/
  main.dart                          # Punto de entrada, MultiProvider, MaterialApp
  firebase_options.dart              # Configuracion de Firebase
  src/
    core/                            # Nucleo del sistema
      config/
        app_config.dart              # Configuracion central (URLs, timeouts, helpers)
        env_config.dart              # Variables de entorno sensibles
      constants/
        app_constants.dart           # Constantes globales (mapas, validacion, etc.)
      error/                         # Manejo de errores centralizado
      utils/                         # Utilidades compartidas
    data/                            # Capa de datos legacy
      database/                      # Conexion directa a BD (deprecado)
      repositories/                  # Repositorios legacy
      sql/                           # Queries SQL (deprecado)
    features/                        # FEATURES por dominio (la mas importante)
      auth/                          # Autenticacion
        presentation/
          screens/                   # Pantallas de login, registro, bienvenida
        widgets/                     # Widgets especificos de auth
      conductor/                     # Funcionalidades del conductor
        data/
          datasources/               # Fuentes de datos remotas
          models/                    # Modelos de datos (JSON parsing)
          repositories/              # Implementacion de repositorios
        domain/
          entities/                  # Entidades de negocio puras
          repositories/              # Contratos/interfaces de repositorios
          usecases/                  # Casos de uso del negocio
        models/                      # Modelos compartidos del conductor
        presentation/
          providers/                 # Providers de presentacion (refactored)
          screens/                   # Pantallas principales
          views/                     # Vistas (tabs dentro de screens)
          widgets/                   # Widgets del conductor
        providers/                   # Providers de estado (legacy/global)
        services/                    # Servicios HTTP directos
        utils/                       # Utilidades del conductor
      admin/                         # Panel administrativo
        data/
        domain/
        presentation/
          screens/
        services/
      user/                          # Funcionalidades del pasajero
        data/
        domain/
        presentation/
          screens/
        services/
      shared/                        # Componentes compartidos entre features
      onboarding/                    # Pantallas de onboarding
      profile/                       # Gestion de perfil
      test/                          # (vaciar si hay tests sueltos aqui)
    global/                          # Configuracion y servicios globales
      config/
        api_config.dart              # URLs base de la API REST
      services/
        admin/                       # AdminService (HTTP)
        auth/                        # UserService, AuthService
        email_service.dart           # Servicio de emails
        nominatim_service.dart       # Geocodificacion OSM
        osm_service.dart             # Servicio de mapas OSM
      states/                        # Estados globales
      widgets/                       # Widgets globales
    providers/                       # Providers raiz
      database_provider.dart         # Provider de BD (legacy)
    routes/                          # Navegacion
      app_router.dart                # Router principal con onGenerateRoute
      route_names.dart               # Constantes de nombres de rutas
      animated_routes.dart           # Transiciones de ruta animadas
    widgets/                         # Widgets reutilizables globales
      auth_wrapper.dart              # Wrapper de autenticacion
      entrance_fader.dart            # Widget de fade-in
      avatars/                       # Componentes de avatar
      dialogs/                       # Dialogos reutilizables
      rating/                        # Widgets de calificacion
      snackbars/
        custom_snackbar.dart         # Snackbar personalizado (showSuccess, showError, etc.)
```

### 2.2 Arquitectura Backend (PHP)

```
backend-deploy/
  .env                               # Variables de entorno del backend (DB_HOST, DB_NAME, etc.)
  config/
    config.php                       # Headers CORS, helpers globales (getJsonInput, sendJsonResponse)
    database.php                     # Clase Database con PDO y carga de .env
  auth/                              # Endpoints de autenticacion
    login.php, register.php, google_login.php, profile.php, etc.
  conductor/                         # Endpoints del conductor
    submit_verification.php          # Enviar solicitud de verificacion
    upload_document.php              # Subir documentos (licencia, SOAT, etc.)
    get_profile.php                  # Obtener perfil del conductor
    get_estadisticas.php             # Estadisticas del dia
    actualizar_disponibilidad.php    # Conectar/desconectar
    accept_assignment.php            # Aceptar asignacion de viaje
    reject_assignment.php            # Rechazar asignacion
    get_balance.php                  # Obtener balance
    get_commission_status.php        # Estado de comision
    submit_commission_payment.php    # Pagar comision
    ...
  admin/                             # Endpoints administrativos
  user/                              # Endpoints del usuario/pasajero
  trips/                             # Gestion de viajes
  utils/                             # Utilidades del backend
  uploads/                           # Archivos subidos (imagenes de documentos)
    conductores/{id}/                # Documentos por conductor
  migrations/                        # Migraciones de base de datos (SQL + PHP)
    001_create_detalles_conductor.sql
    002_mirror_vehiculo_columns.sql
    ...
    README.md
  docs/                              # Documentacion del backend
```

### 2.3 Patron de Comunicacion

```
Flutter App (Dart)
    |
    v
  Services (HTTP)  -->  API REST (PHP)  -->  MySQL (PDO)
    |                        |
    v                        v
  Providers (State)    uploads/ (archivos)
    |
    v
  UI (Widgets/Screens)
```

---

## 3. Sistema de Colores y Tema Visual

### REGLA CRITICA: Usar SIEMPRE los colores globales, NUNCA valores hardcodeados sueltos.

La app usa un tema **oscuro premium** (dark mode). Los colores principales son:

| Color | Valor | Uso |
|-------|-------|-----|
| **Fondo principal** | `Colors.black` / `#000000` | Scaffold, fondo general |
| **Superficie/tarjeta** | `Color(0xFF1A1A1A)` | Cards, containers, modales |
| **Superficie elevada** | `Color(0xFF1E1E1E)` | Dialogs, bottom sheets |
| **Superficie hover** | `Color(0xFF2A2A2A)` | Shimmer highlight, estados hover |
| **Color primario (amarillo)** | `Color(0xFFFFFF00)` | Botones, acentos, iconos activos |
| **Color dorado** | `Color(0xFFFFD700)` | Estrellas de calificacion, iconos premium |
| **Texto principal** | `Colors.white` | Titulos, texto importante |
| **Texto secundario** | `Colors.white.withOpacity(0.6-0.7)` | Subtitulos, labels |
| **Texto terciario** | `Colors.white.withOpacity(0.3-0.5)` | Hints, placeholders |
| **Borde sutil** | `Colors.white.withOpacity(0.1)` | Bordes de tarjetas glass |
| **Error/Peligro** | `Colors.red` / `Color(0xFFf5576c)` | Botones destructivos, alertas |
| **Exito** | `Colors.green` | Estado online, confirmaciones |
| **Advertencia** | `Colors.orange` | Estado pendiente, alertas moderadas |

### Estilo Visual (Glassmorphism Premium)

- **Tarjetas**: Fondo `Color(0xFF1A1A1A).withOpacity(0.6-0.8)`, borde `Colors.white.withOpacity(0.1)`, border-radius `16-24px`
- **Efecto Glass**: Usar `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))`
- **Iconos**: SIEMPRE usar `Icons.*` de Material Design, NUNCA emojis
- **Bordes redondeados**: Radio de `12-24px` segun contexto
- **Sombras**: Sutiles con color primario para elementos destacados
- **Animaciones**: Suaves con `AnimatedContainer`, `animate_do`, transiciones de 300ms

### REGLAS DE UI ESTRICTAS

1. **NUNCA usar emojis** en la interfaz. Siempre usar iconos de Material Design (`Icons.*`)
2. **NUNCA hardcodear colores** directamente en widgets. Referenciar los colores del tema
3. **Seguir el estilo existente** de la app en toda nueva pantalla
4. **Usar widgets reutilizables** cuando el codigo se repite mas de 2 veces
5. **Extraer widgets** a archivos separados cuando un metodo build supera ~100 lineas
6. **Usar `CustomSnackbar`** para notificaciones (no `ScaffoldMessenger` directo)
7. **Disenar tipo plataforma profesional** (Uber, Didi, InDrive) - premium, limpio, moderno
8. **Efectos de Carga (Shimmer)**: SIEMPRE usar `CustomShimmer` (ej. `CustomShimmer.listCards()`, `CustomShimmer.profile()`) en lugar de `CircularProgressIndicator` para cargar pantallas completas, listas, historiales o perfiles. Solo usar `CircularProgressIndicator` para botones o acciones pequenas.

---

## 4. Patrones de Diseno a Seguir

Referencia: https://refactoring.guru/es/design-patterns/catalog

### En Flutter (Frontend)

| Patron | Uso en PingGo |
|--------|---------------|
| **Repository Pattern** | `data/repositories/` - Abstrae fuentes de datos |
| **Provider Pattern** | Estado global con `ChangeNotifierProvider` |
| **Factory Method** | Crear widgets/modelos desde JSON (`fromJson`) |
| **Strategy** | Diferentes servicios de mapa (OSM, Carto) |
| **Observer** | Providers que notifican cambios a la UI |
| **Facade** | Services que simplifican llamadas HTTP complejas |
| **Template Method** | Screens base con metodos `build*` compartidos |

### En PHP (Backend)

| Patron | Uso en PingGo |
|--------|---------------|
| **Singleton** | Clase `Database` con conexion unica |
| **Repository** | Cada archivo PHP agrupa operaciones de una tabla |
| **Strategy** | Diferentes tipos de documentos en `upload_document.php` |
| **Chain of Responsibility** | Validaciones en cadena antes de procesar requests |

### Reglas de Organizacion de Archivos

- Si una carpeta tiene **mas de 8 archivos** del mismo tipo, crear subcarpetas tematicas
- Ejemplo: `conductor/` con 22 archivos deberia tener subcarpetas como:
  - `conductor/perfil/` (get_profile, update_profile)
  - `conductor/viajes/` (accept_assignment, reject_assignment)
  - `conductor/documentos/` (upload_document, upload_documents)
  - `conductor/comisiones/` (get_commission_status, submit_commission_payment)
- **Mantener compatibilidad**: Al reorganizar, actualizar las rutas en los services de Flutter

---

## 5. Convenciones de Codigo

### 5.1 Dart (Flutter)

```dart
// -- CORRECTO: Comentarios en espanol explicando el "por que" --
/// Servicio para gestionar operaciones del conductor.
/// Comunica con la API REST del backend en /conductor/*.
class ConductorService {
  /// Envia la solicitud de verificacion al backend.
  /// Retorna un Map con 'success' y 'message'.
  static Future<Map<String, dynamic>> submitVerification({
    required int usuarioId,
    required String numeroLicencia,
    // ...
  }) async {
    // Construir la URL del endpoint de verificacion
    final url = '${ApiConfig.conductorEndpoint}/submit_verification.php';
    // ...
  }
}
```

- **Nombres de clases**: PascalCase (`ConductorService`, `DriverTripScreen`)
- **Nombres de variables/metodos**: camelCase (`_fetchStats`, `conductorUser`)
- **Nombres de archivos**: snake_case (`conductor_service.dart`)
- **Constantes**: UPPER_SNAKE_CASE para enums, camelCase con `static const` para valores
- **Comentarios**: EN ESPANOL, documentar el "por que", no el "que"
- **Imports**: Agrupar por paquetes Flutter, luego paquetes externos, luego locales

### 5.2 PHP (Backend)

```php
<?php
// backend-deploy/conductor/get_profile.php
// Obtener el perfil completo del conductor incluyendo datos del vehiculo.
// Requiere: conductor_id (GET o POST)

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
// ... headers CORS estandar

require_once __DIR__ . '/../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Validar parametros de entrada
    // ...
    
    // Ejecutar query con prepared statements (SIEMPRE)
    $stmt = $db->prepare("SELECT * FROM detalles_conductor WHERE usuario_id = ?");
    $stmt->execute([$usuario_id]);
    
    // Responder con JSON estandar
    echo json_encode([
        'success' => true,
        'data' => $result
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
```

- **SIEMPRE usar prepared statements** (nunca concatenar SQL)
- **SIEMPRE devolver JSON** con formato `{'success': bool, 'message': string, 'data': mixed}`
- **SIEMPRE incluir headers CORS** al inicio
- **SIEMPRE manejar OPTIONS** para preflight requests
- **Comentarios en espanol** explicando el proposito del archivo

### 5.3 SQL (Migraciones)

```sql
-- migrations/011_nueva_funcionalidad.sql
-- Descripcion: Agregar columna X a la tabla Y para soportar Z
-- Fecha: 2026-04-26
-- Autor: [nombre]

-- Verificar si la columna ya existe antes de agregar
ALTER TABLE detalles_conductor 
ADD COLUMN IF NOT EXISTS nueva_columna VARCHAR(255) DEFAULT NULL
COMMENT 'Descripcion de la columna';
```

- Numerar secuencialmente: `011_`, `012_`, etc.
- Incluir script PHP de ejecucion: `run_migration_011.php`
- **NUNCA modificar migraciones existentes**, crear una nueva
- Documentar cambios en `migrations/README.md`

---

## 6. Despliegue y Servidor

### 6.1 Servidor de Produccion

- **IP**: `2.24.223.16` (referenciada en `.env` como `SERVER_IP`)
- **Acceso SSH**: `ssh root@2.24.223.16`
- **Stack**: Apache + PHP + MySQL en Linux
- **Ruta del proyecto en servidor**: Verificar con `ls /var/www/html/` al conectar

### 6.2 REGLA OBLIGATORIA: Actualizar Servidor Despues de Cada Cambio en Backend

> **CRITICO**: Cada vez que se modifique CUALQUIER archivo dentro de `backend-deploy/`,
> el agente DEBE subir los cambios al servidor de produccion y validar que no haya errores.
> NO se considera completa una tarea de backend hasta que el servidor este actualizado y verificado.

#### Flujo Obligatorio de Despliegue Backend

```bash
# ==============================================================
# PASO 1: Subir archivos modificados al servidor
# ==============================================================
# Opcion A: Subir archivo(s) especifico(s) (RECOMENDADO para cambios puntuales)
scp backend-deploy/conductor/archivo_modificado.php root@2.24.223.16:/var/www/html/backend-deploy/conductor/

# Opcion B: Subir una carpeta completa
scp -r backend-deploy/conductor/* root@2.24.223.16:/var/www/html/backend-deploy/conductor/

# Opcion C: Subir todo el backend (solo si hay muchos cambios)
scp -r backend-deploy/* root@2.24.223.16:/var/www/html/backend-deploy/

# ==============================================================
# PASO 2: Conectar al servidor y validar
# ==============================================================
ssh root@2.24.223.16

# Navegar al directorio del proyecto
cd /var/www/html/

# ==============================================================
# PASO 3: Verificar sintaxis PHP (detectar errores antes de que afecten)
# ==============================================================
# Verificar un archivo especifico
php -l backend-deploy/conductor/archivo_modificado.php

# Verificar todos los archivos PHP de una carpeta
find backend-deploy/conductor/ -name "*.php" -exec php -l {} \;

# ==============================================================
# PASO 4: Verificar que el sistema responde correctamente
# ==============================================================
# Test de conectividad del sistema general
curl -s http://localhost/verify_system_json.php | python3 -m json.tool

# Test del endpoint especifico que se modifico (ejemplo)
curl -s -X POST http://localhost/backend-deploy/conductor/get_profile.php \
  -H "Content-Type: application/json" \
  -d '{"conductor_id": 1}' | python3 -m json.tool

# ==============================================================
# PASO 5: Revisar logs de Apache por errores
# ==============================================================
tail -20 /var/log/apache2/error.log
# O si es nginx:
# tail -20 /var/log/nginx/error.log

# ==============================================================
# PASO 6: Verificar permisos (si se subieron archivos nuevos)
# ==============================================================
chmod -R 755 backend-deploy/
chmod -R 755 uploads/
chown -R www-data:www-data uploads/
```

#### Validacion Rapida de Errores (Resumen)

| Comando | Que valida | Resultado esperado |
|---------|-----------|--------------------|
| `php -l archivo.php` | Sintaxis PHP | "No syntax errors detected" |
| `curl -s http://localhost/verify_system_json.php` | Sistema general | `{"success": true}` |
| `curl -s http://localhost/backend-deploy/endpoint.php` | Endpoint especifico | JSON valido sin errores |
| `tail -20 /var/log/apache2/error.log` | Logs del servidor | Sin errores recientes |

#### Procedimiento de Rollback (Si Algo Falla)

```bash
# Si un cambio rompe algo en produccion:

# 1. Identificar el archivo que causo el problema
tail -50 /var/log/apache2/error.log

# 2. Revertir al archivo anterior (si se hizo backup)
cp archivo_modificado.php.bak archivo_modificado.php

# 3. O revertir desde git (si el servidor tiene git)
git checkout -- backend-deploy/conductor/archivo_modificado.php

# 4. Verificar que el sistema vuelve a funcionar
curl -s http://localhost/verify_system_json.php
```

### 6.3 Proceso de Despliegue de Migraciones

```bash
# 1. Subir la migracion al servidor
scp backend-deploy/migrations/011_nueva_migracion.sql root@2.24.223.16:/var/www/html/backend-deploy/migrations/
scp backend-deploy/migrations/run_migration_011.php root@2.24.223.16:/var/www/html/backend-deploy/migrations/

# 2. Conectar y ejecutar la migracion
ssh root@2.24.223.16
cd /var/www/html/backend-deploy
php migrations/run_migration_011.php

# 3. Verificar que la migracion se aplico correctamente
mysql -u root -p -e "DESCRIBE tabla_modificada;" nombre_bd

# 4. Verificar que los endpoints que usan esa tabla siguen funcionando
curl -s http://localhost/backend-deploy/conductor/get_profile.php \
  -H "Content-Type: application/json" \
  -d '{"conductor_id": 1}'
```

### 6.4 Proceso de Build del Frontend

```bash
# Desde la maquina local (Windows)
cd c:\Flutter\ping_go

# Verificar que .env tiene la IP correcta
# SERVER_IP=2.24.223.16

# Build APK de release
flutter build apk --release

# Build App Bundle para Google Play
flutter build appbundle --release

# El APK se genera en:
# build/app/outputs/flutter-apk/app-release.apk
```

### 6.5 Configuracion de API segun Entorno

En `lib/src/global/config/api_config.dart`:
- **Emulador Android**: `SERVER_IP=10.0.2.2` (redirige a localhost del host)
- **Dispositivo fisico**: `SERVER_IP=192.168.X.X` (IP de la maquina en la red local)
- **Produccion**: `SERVER_IP=2.24.223.16` (servidor remoto)

Cuando `SERVER_IP=76.13.127.228`, la URL es directamente `http://$ip` (sin `/ping_go/backend-deploy`).
Para otros IPs, la URL es `http://$ip/ping_go/backend-deploy`.

### 6.6 Checklist de Despliegue Backend (Uso Obligatorio)

Cada vez que se modifique el backend, completar TODOS estos pasos:

- [ ] Archivos modificados subidos al servidor con `scp`
- [ ] Sintaxis PHP verificada con `php -l` (sin errores)
- [ ] Endpoint(s) modificado(s) probado(s) con `curl`
- [ ] Logs de Apache/Nginx revisados (sin errores nuevos)
- [ ] Permisos de archivos correctos (755 para PHP, uploads con www-data)
- [ ] Si hay migracion: ejecutada y verificada en el servidor
- [ ] Sistema general verificado con `verify_system_json.php`

---

## 7. Base de Datos

### 7.1 Tablas Principales

| Tabla | Descripcion |
|-------|-------------|
| `usuarios` | Usuarios del sistema (todos los roles) |
| `detalles_conductor` | Informacion de verificacion del conductor |
| `solicitudes_viaje` | Solicitudes de viaje de pasajeros |
| `asignaciones_viaje` | Asignacion de viajes a conductores |
| `transacciones` | Registro de pagos y cobros |
| `calificaciones` | Calificaciones conductor<->pasajero |
| `comisiones_pagos` | Historial de pagos de comisiones |
| `tarifas` | Configuracion de tarifas por tipo vehiculo |

### 7.2 Campos Clave de `detalles_conductor`

```sql
usuario_id, numero_licencia, vencimiento_licencia, tipo_vehiculo,
marca_vehiculo, modelo_vehiculo, ano_vehiculo, color_vehiculo,
placa_vehiculo, aseguradora, numero_poliza_seguro, vencimiento_seguro,
estado_aprobacion, aprobado, motivo_rechazo,
foto_licencia_frente, foto_licencia_reverso,
latitud, longitud, disponible, en_servicio
```

### 7.3 Reglas de Migraciones

1. Crear archivo SQL numerado: `XXX_descripcion.sql`
2. Crear script PHP de ejecucion: `run_migration_XXX.php`
3. El script PHP debe:
   - Conectar a la BD via `Database` class
   - Verificar si la migracion ya fue aplicada
   - Ejecutar el SQL
   - Reportar exito/error
4. Documentar en `migrations/README.md`
5. **NUNCA borrar datos existentes** sin respaldo previo

---

## 8. Estructura de Documentacion

Toda documentacion debe ir en `docs/` organizada asi:

```
docs/
  INDEX.md                           # Indice general
  COMANDOS_UTILES.md                 # Comandos frecuentes
  REQUERIMIENTOS_FUNCIONALES_NO_FUNCIONALES.md
  architecture/                      # Documentacion de arquitectura
  admin/                             # Guias del administrador
  conductor/                         # Guias del conductor
  user/                              # Guias del usuario
  deployment/                        # Guias de despliegue
  integrations/                      # Integraciones externas
  testing/                           # Guias de testing
  troubleshooting/                   # Solucion de problemas
  glossary/                          # Glosario de terminos
```

### Reglas de Documentacion

- **Idioma**: ESPANOL
- **Formato**: Markdown
- **Sin emojis** en documentos tecnicos (usar iconos solo en README.md externo)
- Documentar **decisiones de diseno** y el "por que" de cada componente
- Mantener actualizado el `INDEX.md` cuando se agreguen nuevos documentos

---

## 9. Reglas para Agentes IA

### ANTES de escribir codigo:

1. **Leer esta skill completa** para entender el contexto
2. **Revisar los archivos existentes** relacionados con la tarea
3. **Seguir la arquitectura establecida** - no crear estructuras nuevas sin justificacion
4. **Usar los colores globales** definidos en la seccion 3
5. **Verificar si ya existe un widget reutilizable** antes de crear uno nuevo

### AL escribir codigo:

1. **Comentarios en ESPANOL** - documentar el "por que", no el "que"
2. **NUNCA emojis** en la UI - siempre Material Icons
3. **NUNCA colores hardcodeados** - usar las constantes del tema
4. **Extraer widgets** cuando el codigo se repita o sea muy largo (>100 lineas)
5. **Seguir patrones de diseno** de refactoring.guru cuando aplique
6. **Codigo limpio** - sin prints de debug en produccion, sin variables sin usar
7. **Manejo de errores** - siempre try/catch, mostrar mensajes al usuario con `CustomSnackbar`
8. **Prepared statements** en PHP - NUNCA concatenar SQL

### AL crear archivos nuevos:

1. **Seguir la estructura de carpetas existente**
2. **Nombrar archivos en snake_case** (Dart y PHP)
3. **No crear archivos de test sueltos** fuera de `test/` - si se crean, moverlos a `test/`
4. **Eliminar archivos temporales** (debug, test scripts) al terminar
5. **Si hay mas de 8 archivos** en una carpeta, crear subcarpetas tematicas

### DESPUES de escribir codigo:

1. **Verificar que no se rompio nada** existente
2. **Actualizar documentacion** en `docs/` si se agrego funcionalidad nueva
3. **Si se modifico la BD**, crear la migracion correspondiente
4. **Si se modifico el backend**, OBLIGATORIAMENTE:
   a. Subir los archivos al servidor con `scp ... root@2.24.223.16:...`
   b. Verificar sintaxis con `ssh root@2.24.223.16 'php -l /ruta/archivo.php'`
   c. Probar el endpoint con `curl` para confirmar que responde correctamente
   d. Revisar logs del servidor con `tail /var/log/apache2/error.log`
   e. Seguir el checklist completo de la seccion 6.6
5. **Si se modifico el frontend**, OBLIGATORIAMENTE ejecutar una validacion global de flutter (`flutter analyze --no-pub`) en TODO el proyecto para asegurar que no haya errores de importaciones rotas o rutas invalidas, no solo en los archivos modificados.
6. **Revisar errores de compilacion**: Siempre corrige cualquier error que se introduzca (ej. imports faltantes, variables o getters no definidos).
7. **Sincronizar validaciones frontend/backend**: Si el backend valida estados permitidos (ej. estados cancelables de un viaje), el frontend DEBE respetar exactamente esas mismas reglas. NUNCA permitir en la UI una accion que el backend va a rechazar.
8. **Proteccion anti doble-tap**: Todo boton que dispare una llamada HTTP (cancelar, enviar, confirmar) DEBE tener un flag `_isProcessing` que evite multiples llamadas simultaneas al pulsarlo repetidamente.
---

## 10. Dependencias Principales

### Flutter

| Paquete | Uso |
|---------|-----|
| `provider` | Gestion de estado |
| `flutter_bloc` | Patron BLoC (complementario) |
| `http` | Llamadas HTTP a la API |
| `flutter_map` + `latlong2` | Mapas con OSM |
| `geolocator` + `geocoding` | Geolocalizacion |
| `image_picker` | Seleccion de imagenes |
| `shared_preferences` | Almacenamiento local |
| `shimmer` | Efectos de carga skeleton |
| `intl` | Internacionalizacion y formato |
| `fl_chart` | Graficos y estadisticas |
| `animate_do` | Animaciones declarativas |
| `firebase_core` + `firebase_auth` | Firebase y auth Google |
| `google_sign_in` | Login con Google |
| `font_awesome_flutter` | Iconos adicionales |
| `audioplayers` | Reproduccion de audio |

### Backend PHP

| Paquete | Uso |
|---------|-----|
| `vlucas/phpdotenv` | Carga de variables de entorno |
| PDO nativo | Conexion a MySQL |

---

## 11. Cuentas de Prueba

| Tipo | Email | Contrasena |
|------|-------|------------|
| Admin | admin@pingo.test | prueba1234 |
| Conductor | conductor@pingo.test | prueba1234 |
| Usuario | usuario@pingo.test | prueba1234 |

---

## 12. Checklist de Calidad

Antes de considerar una tarea completa, verificar:

### Codigo General
- [ ] Codigo comentado en espanol
- [ ] Sin emojis en la UI (solo Material Icons)
- [ ] Colores usando constantes del tema (no hardcodeados)
- [ ] Widgets extraidos si hay codigo repetido
- [ ] Manejo de errores con try/catch
- [ ] Archivos en la carpeta correcta segun la arquitectura
- [ ] Sin archivos de debug/test sueltos fuera de `test/`
- [ ] Documentacion actualizada en `docs/` (si aplica)

### Frontend (Flutter/Dart)
- [ ] `flutter analyze` ejecutado sin errores criticos
- [ ] Estilo visual consistente con el resto de la app (glassmorphism, dark mode)
- [ ] Responsive y usable en diferentes tamanos de pantalla
- [ ] Usando `CustomSnackbar` para notificaciones (no ScaffoldMessenger directo)

### Backend (PHP)
- [ ] Prepared statements en PHP (no SQL concatenado)
- [ ] Headers CORS incluidos en endpoints nuevos
- [ ] Manejo de OPTIONS para preflight requests
- [ ] Respuesta JSON con formato estandar `{success, message, data}`
- [ ] **ARCHIVOS SUBIDOS AL SERVIDOR** con `scp ... root@2.24.223.16:...`
- [ ] **SINTAXIS VERIFICADA** en servidor con `php -l`
- [ ] **ENDPOINT PROBADO** con `curl` en el servidor
- [ ] **LOGS REVISADOS** sin errores nuevos en Apache/Nginx

### Base de Datos
- [ ] Migracion creada si se modifico la BD
- [ ] Migracion ejecutada y verificada en el servidor
- [ ] Script PHP de ejecucion incluido (`run_migration_XXX.php`)
- [ ] README de migraciones actualizado