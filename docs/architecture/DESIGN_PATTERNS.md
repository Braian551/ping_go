# Patrones de Diseño - PingGo App

## 📋 Información General

Este documento describe los patrones de diseño arquitectónicos y de desarrollo implementados en la aplicación PingGo, siguiendo las mejores prácticas de Flutter y desarrollo móvil.

## 🏗️ Patrones Arquitectónicos

### 1. Clean Architecture

#### Descripción
La aplicación sigue los principios de **Clean Architecture** propuestos por Robert C. Martin, separando el código en capas concéntricas con dependencias hacia adentro.

#### Estructura Implementada
```
Features/
├── Presentation Layer (Widgets, Screens, Providers)
├── Domain Layer (Entities, Use Cases, Repositories Interfaces)
└── Data Layer (Models, Repositories Impl, Data Sources)
```

#### Beneficios
- **Independencia de Frameworks**: El código de negocio no depende de Flutter
- **Testabilidad**: Cada capa puede ser testeada independientemente
- **Mantenibilidad**: Cambios en una capa no afectan otras
- **Escalabilidad**: Fácil agregar nuevas funcionalidades

### 2. Provider Pattern

#### Descripción
Usado para manejo de estado e inyección de dependencias siguiendo el patrón Observer.

#### Implementación
```dart
class MyProvider extends ChangeNotifier {
  // Estado
  String _data = '';

  // Getter
  String get data => _data;

  // Método que actualiza estado y notifica
  void updateData(String newData) {
    _data = newData;
    notifyListeners(); // Notifica a los listeners
  }
}
```

#### Uso en Widgets
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        return Text(provider.data);
      },
    );
  }
}
```

#### Beneficios
- **Simplicidad**: Fácil de entender y usar
- **Performance**: Solo reconstruye widgets que escuchan cambios
- **Composición**: Múltiples providers pueden trabajar juntos

## 🎯 Patrones de Presentación

### 1. BLoC Pattern (Business Logic Component)

#### Descripción
Aunque principalmente usamos Provider, algunos componentes complejos usan BLoC para lógica de negocio más sofisticada.

#### Estructura
```
lib/src/features/auth/
├── presentation/
│   ├── bloc/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   └── screens/
│       └── login_screen.dart
```

#### Estados y Eventos
```dart
// Estados
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {}

// Eventos
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}
```

### 2. Widget Composition

#### Descripción
Los widgets complejos se construyen componiendo widgets más pequeños y reutilizables.

#### Ejemplo
```dart
class ServiceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ServiceIcon(),
          ServiceTitle(),
          ServiceActions(),
        ],
      ),
    );
  }
}
```

#### Beneficios
- **Reutilización**: Componentes modulares
- **Mantenibilidad**: Fácil modificar partes individuales
- **Testabilidad**: Cada widget puede ser testeado por separado

## 🔄 Patrones de Datos

### 1. Repository Pattern

#### Descripción
Abstrae el acceso a datos, permitiendo cambiar la fuente de datos sin afectar la lógica de negocio.

#### Estructura
```dart
// Interfaz del repositorio
abstract class UserRepository {
  Future<User> getUser(int id);
  Future<void> saveUser(User user);
}

// Implementación
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  @override
  Future<User> getUser(int id) async {
    // Lógica para obtener usuario (cache/local/remote)
  }
}
```

#### Beneficios
- **Abstracción**: Lógica de negocio independiente de la fuente de datos
- **Testabilidad**: Fácil mockear repositorios en tests
- **Flexibilidad**: Cambiar entre diferentes fuentes de datos

### 2. Data Source Pattern

#### Descripción
Separa las diferentes fuentes de datos (API, base de datos local, cache, etc.).

#### Tipos de Data Sources
- **RemoteDataSource**: APIs REST, GraphQL
- **LocalDataSource**: SQLite, SharedPreferences
- **CacheDataSource**: Memoria, archivos temporales

### 3. Model-Entity Mapping

#### Descripción
Los modelos de datos (DTOs) se mapean a entidades del dominio.

```dart
// Modelo de API
class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      email = json['email'];
}

// Entidad de dominio
class User {
  final UserId id;
  final String name;
  final Email email;
}

// Mapper
class UserMapper {
  static User fromModel(UserModel model) {
    return User(
      id: UserId(model.id),
      name: model.name,
      email: Email(model.email),
    );
  }
}
```

## 🧩 Patrones de UI/UX

### 1. Glassmorphism Effect

#### Descripción
Efecto visual con transparencias y desenfoques para crear interfaces modernas.

#### Implementación
```dart
class GlassContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: child,
      ),
    );
  }
}
```

### 2. Shimmer Loading

#### Descripción
Animaciones de carga que simulan el contenido real.

#### Uso
```dart
class LoadingServiceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

## 🔧 Patrones de Utilidad

### 1. Singleton Pattern

#### Descripción
Usado para servicios globales como configuración de API, logging, etc.

#### Ejemplo
```dart
class ApiConfig {
  static final ApiConfig _instance = ApiConfig._internal();

  factory ApiConfig() => _instance;

  ApiConfig._internal();

  String get baseUrl => 'https://api.pinggo.com';
}
```

### 2. Factory Pattern

#### Descripción
Para crear diferentes tipos de objetos basados en parámetros.

#### Ejemplo
```dart
abstract class PaymentMethod {
  void processPayment(double amount);
}

class CreditCardPayment implements PaymentMethod {
  @override
  void processPayment(double amount) {
    // Lógica para pago con tarjeta
  }
}

class PayPalPayment implements PaymentMethod {
  @override
  void processPayment(double amount) {
    // Lógica para pago con PayPal
  }
}

class PaymentFactory {
  static PaymentMethod createPaymentMethod(String type) {
    switch (type) {
      case 'credit_card':
        return CreditCardPayment();
      case 'paypal':
        return PayPalPayment();
      default:
        throw UnsupportedError('Tipo de pago no soportado');
    }
  }
}
```

## 🧪 Patrones de Testing

### 1. Unit Testing

#### Descripción
Tests que verifican unidades individuales de código.

#### Ejemplo
```dart
void main() {
  group('UserRepository', () {
    test('should return user when getUser is called', () async {
      // Arrange
      final mockDataSource = MockUserDataSource();
      final repository = UserRepositoryImpl(mockDataSource);

      // Act
      final result = await repository.getUser(1);

      // Assert
      expect(result, isA<User>());
    });
  });
}
```

### 2. Widget Testing

#### Descripción
Tests que verifican el comportamiento de widgets.

#### Ejemplo
```dart
void main() {
  testWidgets('LoginScreen shows error message on invalid credentials',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(const LoginScreen());

    // Act
    await tester.enterText(find.byType(TextField).first, 'invalid@email.com');
    await tester.enterText(find.byType(TextField).last, 'wrongpassword');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Assert
    expect(find.text('Credenciales inválidas'), findsOneWidget);
  });
}
```

### 3. Integration Testing

#### Descripción
Tests que verifican la integración entre diferentes partes del sistema.

#### Ejemplo
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete login flow', (WidgetTester tester) async {
    // Test completo del flujo de login
  });
}
```

## 📱 Patrones Móviles Específicos

### 1. Platform-Specific Code

#### Descripción
Código que se comporta diferente en iOS y Android.

#### Implementación
```dart
class PlatformUtils {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  static Widget buildPlatformButton() {
    if (isIOS) {
      return CupertinoButton(/* iOS style */);
    } else {
      return ElevatedButton(/* Android style */);
    }
  }
}
```

### 2. Permission Handling

#### Descripción
Gestión de permisos de dispositivo (GPS, cámara, etc.).

#### Patrón
```dart
class PermissionService {
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }
}
```

## 🔄 Patrones de Navegación

### 1. Named Routes

#### Descripción
Uso de rutas nombradas en lugar de navegación imperativa.

#### Ventajas
- **Type Safety**: Menos errores de tipeo
- **Centralización**: Todas las rutas en un lugar
- **Mantenibilidad**: Fácil cambiar rutas

#### Implementación
```dart
class RouteNames {
  static const String home = '/home';
  static const String login = '/login';
  static const String profile = '/profile';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      // ...
    }
  }
}
```

### 2. Route Guards

#### Descripción
Protección de rutas basada en estado de autenticación.

#### Ejemplo
```dart
class AuthGuard {
  static bool canAccessRoute(String routeName, User? user) {
    final protectedRoutes = [RouteNames.profile, RouteNames.settings];

    if (protectedRoutes.contains(routeName) && user == null) {
      return false;
    }

    return true;
  }
}
```

## 🎨 Patrones de Animación

### 1. Animated Routes

#### Descripción
Transiciones animadas entre pantallas para mejor UX.

#### Implementación
```dart
class FadeSlidePageRoute extends PageRouteBuilder {
  final Widget page;

  FadeSlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        );
}
```

## 📋 Conclusión

La aplicación PingGo implementa una combinación efectiva de patrones de diseño que garantizan:

- **Mantenibilidad**: Código organizado y fácil de modificar
- **Escalabilidad**: Arquitectura que soporta crecimiento
- **Testabilidad**: Código diseñado para ser testeado
- **Performance**: Patrones optimizados para Flutter
- **User Experience**: UI/UX moderna y responsiva

Cada patrón se selecciona basado en su adecuación al contexto específico de Flutter y las necesidades de una aplicación móvil de transporte.

---

*Última actualización: $(date '+%Y-%m-%d')*