# Ping-Go 🚗

**Aplicación móvil de transporte desarrollada con Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

## 📱 Descripción

Ping-Go es una aplicación móvil completa de transporte que conecta usuarios con conductores para viajes seguros y eficientes. La aplicación ofrece una experiencia moderna con mapas interactivos, sistema de autenticación robusto y gestión completa de viajes.

### ✨ Características Principales

- 🔐 **Autenticación Multi-Rol**: Soporte para usuarios, conductores y administradores
- 🗺️ **Mapas Interactivos**: Integración con OpenStreetMap y servicios de geocodificación
- 🚗 **Gestión de Viajes**: Solicitud, seguimiento y calificación de viajes
- 👤 **Perfiles de Usuario**: Gestión completa de perfiles y documentos
- 📊 **Panel Administrativo**: Dashboard completo para gestión del sistema
- 💰 **Sistema de Pagos**: Integración con métodos de pago
- 📱 **UI Moderna**: Interfaz de usuario con diseño glassmorphism y animaciones

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** con separación clara de responsabilidades:

```
lib/
├── src/
│   ├── core/           # Lógica de negocio y utilidades
│   ├── features/       # Funcionalidades por dominio
│   ├── global/         # Servicios globales
│   ├── providers/      # State management (Provider)
│   ├── routes/         # Configuración de navegación
│   └── widgets/        # Componentes reutilizables
```

### 📂 Estructura de Features

- **Auth**: Autenticación y registro de usuarios
- **User**: Funcionalidades del pasajero
- **Conductor**: Gestión de conductores y documentos
- **Admin**: Panel de administración

## 🚀 Inicio Rápido

### Prerrequisitos

- **Flutter**: `>=3.8.0`
- **Dart**: `>=3.8.0`
- **Android Studio** o **VS Code** con Flutter extension
- **Dispositivo físico** o emulador para testing

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/Braian551/pingo.git
   cd pingo
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**
   ```bash
   # Copiar archivo de configuración
   cp lib/src/core/config/env_config.dart.example lib/src/core/config/env_config.dart

   # Editar las API keys y configuraciones necesarias
   ```

4. **Ejecutar la aplicación**
   ```bash
   # Para Android
   flutter run

   # Para iOS (solo en macOS)
   flutter run --flavor ios

   # Para Web
   flutter run -d chrome
   ```

### 🔑 Cuentas de Prueba

Para facilitar el testing y desarrollo, puedes acceder con las siguientes cuentas de prueba:

**Contraseña común para todas las cuentas:** `prueba1234`

| ID | Tipo | Nombre | Email | Teléfono |
|----|------|--------|-------|----------|
| `admin_690d586cbdc8d` | Administrador | Sistema | admin@pingo.test | +573001111111 |
| `conductor_690d586cbdca7` | Conductor | Prueba | conductor@pingo.test | +573002222222 |
| `usuario_690d586cbdca8` | Usuario | Prueba | usuario@pingo.test | +573003333333 |

**Notas:**
- Estas cuentas están disponibles tanto en desarrollo como en producción
- El administrador tiene acceso completo al panel de gestión
- El conductor puede gestionar viajes y documentos
- El usuario puede solicitar y calificar viajes

## 📋 Scripts Disponibles

```bash
# Ejecutar aplicación en modo debug
flutter run

# Ejecutar tests
flutter test

# Verificar linting
flutter analyze

# Formatear código
flutter format .

# Generar iconos de launcher
flutter pub run flutter_launcher_icons

# Construir APK para Android
flutter build apk --release

# Construir IPA para iOS
flutter build ios --release
```

## 🔧 Configuración

### Variables de Entorno

El archivo `lib/src/core/config/env_config.dart` contiene todas las configuraciones necesarias:

- **APIs de Mapas**: OpenStreetMap, TomTom
- **APIs de Backend**: URLs de servicios REST
- **Configuración de Email**: SMTP settings
- **Límites de Cuota**: Rate limiting

### Conexión al Backend en desarrollo (Laragon)

- Por defecto la app usa `http://10.0.2.2/ping_go/backend-deploy` como `ApiConfig.baseUrl`, que funciona en el emulador de Android porque 10.0.2.2 es la IP del host desde el emulador.
- Si estás usando Laragon y un emulador Android, asegúrate de que la carpeta `backend-deploy` esté disponible en `C:\laragon\www\ping_go` y que puedas abrir `http://localhost/ping_go/backend-deploy/verify_system_json.php` en tu navegador.
- Para pruebas en un dispositivo físico, sustituye `10.0.2.2` por la IP de tu máquina (ej: `http://192.168.1.100/ping_go/backend-deploy`) o crea un host virtual (ej: `pinggo.test`) y usar la IP correspondiente en `lib/src/global/config/api_config.dart`.
- Si la app da 404, abre la URL de verificación en tu navegador para confirmar si existe: `/verify_system_json.php`.


### Servicios Externos

La aplicación integra con varios servicios externos:

- **OpenStreetMap**: Mapas gratuitos y geocodificación
- **TomTom**: APIs de tráfico y rutas
- **Backend REST**: Microservicios para lógica de negocio
- **Email Service**: Envío de correos de verificación

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ejecutar tests de integración
flutter test integration_test/
```

## 📦 Build y Despliegue

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build IPA
flutter build ios --release
```

### Web
```bash
# Build para web
flutter build web --release
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea tu rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### 📝 Estándares de Código

- Seguir las [Flutter Guidelines](https://flutter.dev/docs/development/tools/formatting)
- Usar `flutter format` para formateo automático
- Ejecutar `flutter analyze` antes de commits
- Mantener cobertura de tests > 80%

## 📚 Documentación

Toda la documentación detallada se encuentra en la carpeta [`docs/`](./docs/):

- [📖 Arquitectura del Sistema](./docs/arquitectura.md)
- [🔧 Guía de Instalación](./docs/instalacion.md)
- [📱 Guía del Usuario](./docs/usuario.md)
- [🚗 Guía del Conductor](./docs/conductor.md)
- [⚙️ Guía del Administrador](./docs/administrador.md)
- [🔌 APIs y Integraciones](./docs/apis.md)
- [🧪 Guía de Testing](./docs/testing.md)
- [🚀 Guía de Despliegue](./docs/despliegue.md)

## 🐛 Reporte de Bugs

Si encuentras un bug, por favor crea un issue en GitHub con:

- Descripción clara del problema
- Pasos para reproducir
- Información del dispositivo (OS, versión de Flutter)
- Logs de error si es posible

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo de Desarrollo

- **Braian551** - *Desarrollador Principal*
- **Equipo Ping-Go** - *Contribuidores*

## 🙏 Agradecimientos

- Flutter Community por el excelente framework
- OpenStreetMap por los datos de mapas gratuitos
- TomTom por las APIs de navegación
- Toda la comunidad de código abierto

---

**⭐ Si este proyecto te resulta útil, por favor dale una estrella en GitHub!**</content>
<filePath">c:\Flutter\ping_go - copia (3)\README.md