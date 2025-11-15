# Glosario de Términos - PingGo App

## 📚 Términos Generales

### A
- **API (Application Programming Interface)**: Interfaz de programación de aplicaciones. Conjunto de reglas y protocolos que permiten la comunicación entre diferentes sistemas de software.
- **Assets**: Recursos estáticos de la aplicación (imágenes, sonidos, fuentes) que se incluyen en el paquete de la app.

### B
- **Backend**: Parte del sistema que se ejecuta en el servidor, maneja la lógica de negocio, base de datos y APIs.
- **Bloc**: Patrón de manejo de estado en Flutter (Business Logic Component). Separa la lógica de negocio de la UI.

### C
- **Clean Architecture**: Patrón arquitectónico que separa el código en capas concéntricas con dependencias hacia adentro.
- **CRUD**: Create, Read, Update, Delete. Operaciones básicas de base de datos.
- **Cross-platform**: Desarrollo que permite crear aplicaciones para múltiples plataformas desde un solo código base.

### D
- **Dart**: Lenguaje de programación utilizado por Flutter para desarrollar aplicaciones móviles.
- **Data Source**: Fuente de datos en la arquitectura. Puede ser API remota, base de datos local, etc.
- **Dependency Injection**: Patrón de diseño donde las dependencias se inyectan desde fuera en lugar de crearlas internamente.
- **Domain Layer**: Capa de dominio en Clean Architecture que contiene la lógica de negocio y entidades.

### E
- **Entity**: Representación de un objeto de negocio en el dominio de la aplicación.
- **Environment**: Entorno de ejecución (desarrollo, staging, producción) con configuraciones específicas.

### F
- **Feature**: Característica o funcionalidad específica de la aplicación (auth, user, conductor, admin).
- **Flutter**: Framework de desarrollo móvil multiplataforma creado por Google.
- **Framework**: Conjunto de herramientas y librerías que facilitan el desarrollo de software.

### G
- **Geocoding**: Proceso de convertir direcciones en coordenadas geográficas (latitud, longitud).
- **Geolocalización**: Determinación de la ubicación geográfica de un dispositivo.
- **Glassmorphism**: Estilo de diseño UI con efectos de transparencia y desenfoque.

### H
- **Hot Reload**: Característica de Flutter que permite ver cambios en el código inmediatamente sin reiniciar la app.
- **HTTP**: Protocolo de transferencia de hipertexto utilizado para comunicación cliente-servidor.

### I
- **IDE (Integrated Development Environment)**: Entorno de desarrollo integrado (VS Code, Android Studio).
- **Inheritance**: Herencia en programación orientada a objetos.
- **Integration Test**: Pruebas que verifican la integración entre diferentes componentes del sistema.

### J
- **JSON (JavaScript Object Notation)**: Formato de intercambio de datos ligero y legible por humanos.

### L
- **LatLong**: Coordenadas geográficas (latitud y longitud) utilizadas en mapas.
- **Linting**: Análisis estático del código para detectar errores y mejorar la calidad.
- **Local Data Source**: Fuente de datos local (base de datos SQLite, SharedPreferences).

### M
- **Material Design**: Sistema de diseño creado por Google para aplicaciones móviles y web.
- **Middleware**: Software que actúa como intermediario entre diferentes aplicaciones o componentes.
- **Model**: Representación de datos en la capa de datos, usualmente mapeada desde APIs.
- **MVC**: Model-View-Controller, patrón arquitectónico que separa la lógica de negocio de la presentación.

### N
- **Named Routes**: Sistema de navegación en Flutter que utiliza nombres en lugar de rutas directas.
- **Native**: Código específico para una plataforma particular (Android/iOS).

### O
- **Observer Pattern**: Patrón de diseño donde un objeto notifica a otros sobre cambios en su estado.
- **Onboarding**: Proceso de introducción y configuración inicial para nuevos usuarios.

### P
- **Package**: Módulo o librería reutilizable en Dart/Flutter.
- **Persistence**: Capacidad de almacenar datos de forma permanente.
- **Platform Channel**: Mecanismo en Flutter para comunicar código Dart con código nativo (Android/iOS).
- **Presentation Layer**: Capa de presentación en Clean Architecture que maneja la UI y estado.
- **Provider**: Patrón de manejo de estado en Flutter que implementa el patrón Observer.

### R
- **Repository**: Patrón que abstrae el acceso a datos, proporcionando una interfaz consistente.
- **REST API**: API que sigue los principios REST (Representational State Transfer).
- **Reverse Geocoding**: Proceso de convertir coordenadas geográficas en direcciones legibles.

### S
- **SDK (Software Development Kit)**: Conjunto de herramientas para desarrollar software para una plataforma específica.
- **SharedPreferences**: Almacenamiento de clave-valor simple en Flutter para datos persistentes.
- **Shimmer**: Efecto de carga que simula el contenido real con animaciones.
- **Singleton**: Patrón de diseño que garantiza una única instancia de una clase.
- **State Management**: Gestión del estado de la aplicación (datos que cambian con el tiempo).
- **Stateless Widget**: Widget en Flutter que no mantiene estado interno.
- **Stateful Widget**: Widget en Flutter que mantiene estado interno y puede cambiar.

### T
- **Test-Driven Development (TDD)**: Metodología de desarrollo donde se escriben tests antes del código.
- **Theme**: Conjunto de estilos visuales aplicados consistentemente en la aplicación.
- **Token**: Cadena de caracteres utilizada para autenticación y autorización.

### U
- **UI (User Interface)**: Interfaz de usuario, elementos visuales con los que interactúa el usuario.
- **Unit Test**: Prueba que verifica el comportamiento de una unidad individual de código.
- **Use Case**: Caso de uso que representa una acción específica que un usuario puede realizar.
- **UX (User Experience)**: Experiencia de usuario, cómo se siente la interacción con la aplicación.

### V
- **Version Control**: Sistema para rastrear cambios en el código (Git).
- **ViewModel**: Clase que actúa como intermediario entre la UI y el modelo de datos.

### W
- **Widget**: Componente básico de la UI en Flutter, similar a un "componente" en otros frameworks.
- **Widget Tree**: Estructura jerárquica de widgets que conforman la UI de una aplicación Flutter.

## 🚗 Términos Específicos de PingGo

### Funcionalidades de Usuario
- **Solicitud de Servicio**: Petición de transporte realizada por un usuario.
- **Método de Pago**: Forma de pago configurada (tarjeta, efectivo, etc.).
- **Historial de Viajes**: Registro de viajes anteriores del usuario.

### Funcionalidades de Conductor
- **Perfil Profesional**: Información del conductor (licencia, vehículo, etc.).
- **Gestión de Viajes**: Aceptar, gestionar y completar viajes asignados.
- **Disponibilidad**: Estado del conductor (disponible, ocupado, offline).

### Panel de Administración
- **Dashboard**: Panel principal con métricas y estadísticas.
- **Gestión de Usuarios**: Administración de usuarios y conductores del sistema.
- **Auditoría**: Registro de acciones realizadas en el sistema.

### Integraciones
- **API de Mapas**: Servicio externo para mapas y geocodificación.
- **Servicio de Notificaciones**: Sistema para enviar notificaciones push.
- **Pasarela de Pagos**: Sistema para procesar pagos electrónicos.

## 🔧 Términos Técnicos de Flutter

### Widgets Comunes
- **Scaffold**: Estructura básica de una pantalla con AppBar, body, etc.
- **Container**: Widget versátil para contener otros widgets con estilos.
- **Column/Row**: Widgets para organizar hijos vertical/horizontalmente.
- **ListView**: Widget para mostrar listas scrollables.
- **TextField**: Campo de entrada de texto.
- **ElevatedButton**: Botón elevado con sombra.

### Navegación
- **Navigator**: Gestiona la pila de rutas en Flutter.
- **Route**: Representa una pantalla o página en la navegación.
- **MaterialPageRoute**: Ruta que implementa transiciones Material Design.

### Manejo de Estado
- **ChangeNotifier**: Clase base para implementar el patrón Observer.
- **Consumer**: Widget que escucha cambios en un Provider.
- **Selector**: Widget que reconstruye solo cuando cambian propiedades específicas.

### Redes y APIs
- **http**: Paquete para hacer peticiones HTTP.
- **Dio**: Cliente HTTP alternativo con más funcionalidades.
- **JsonSerializable**: Librería para serializar/deserializar JSON.

## 🗄️ Términos de Base de Datos

### MySQL
- **Tabla**: Estructura que almacena datos en filas y columnas.
- **Primary Key**: Campo único que identifica cada registro.
- **Foreign Key**: Campo que referencia la primary key de otra tabla.
- **Query**: Consulta para recuperar o manipular datos.
- **Transaction**: Operación que agrupa múltiples queries como una unidad.

### SQLite
- **Database**: Archivo que contiene tablas, índices y datos.
- **Cursor**: Objeto que permite recorrer resultados de queries.
- **Migration**: Cambio en la estructura de la base de datos.

## 🚀 Términos de Despliegue

### Plataformas
- **Railway**: Plataforma de despliegue en la nube.
- **Render**: Servicio de hosting para aplicaciones web.
- **Nixpacks**: Herramienta para crear imágenes Docker automáticamente.

### DevOps
- **CI/CD**: Integración Continua / Despliegue Continuo.
- **Pipeline**: Secuencia automatizada de pasos para build y deploy.
- **Environment Variables**: Variables de configuración específicas del entorno.

## 🧪 Términos de Testing

### Tipos de Tests
- **Unit Test**: Prueba de unidades individuales (funciones, clases).
- **Widget Test**: Prueba de widgets de Flutter.
- **Integration Test**: Prueba de integración entre componentes.
- **End-to-End Test**: Prueba completa del flujo de usuario.

### Herramientas
- **flutter_test**: Framework de testing de Flutter.
- **Mockito**: Librería para crear mocks en tests.
- **Coverage**: Medida del porcentaje de código cubierto por tests.

## 📱 Términos Móviles

### Android
- **Activity**: Pantalla principal en aplicaciones Android.
- **Manifest**: Archivo de configuración de la aplicación Android.
- **Gradle**: Sistema de build para Android.

### iOS
- **ViewController**: Controlador de vista en iOS.
- **Storyboard**: Archivo que define la UI de la aplicación iOS.
- **CocoaPods**: Gestor de dependencias para iOS.

### Permisos
- **Location Permission**: Permiso para acceder a la ubicación del dispositivo.
- **Camera Permission**: Permiso para usar la cámara.
- **Storage Permission**: Permiso para acceder al almacenamiento.

---

*Última actualización: $(date '+%Y-%m-%d')*