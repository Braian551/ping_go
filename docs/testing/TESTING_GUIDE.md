# Guía de Testing - PingGo App

## 📋 Información General

Esta guía proporciona las estrategias y mejores prácticas para testing en la aplicación PingGo, asegurando calidad, mantenibilidad y confiabilidad del código.

## 🧪 Estrategias de Testing

### Pirámide de Testing

```
     End-to-End Tests
           /|\
          / | \
         /  |  \
   Integration Tests
       /    |    \
      /     |     \
 Unit Tests (Base)
```

### Tipos de Tests Implementados

#### 1. Unit Tests
**Propósito**: Verificar unidades individuales de código (funciones, clases, métodos).

**Alcance**: ~70% de los tests
**Herramientas**: `flutter_test`, `mockito`
**Ubicación**: `test/unit/`

#### 2. Widget Tests
**Propósito**: Verificar el comportamiento de widgets individuales.

**Alcance**: ~20% de los tests
**Herramientas**: `flutter_test`
**Ubicación**: `test/widget/`

#### 3. Integration Tests
**Propósito**: Verificar la integración entre diferentes módulos.

**Alcance**: ~10% de los tests
**Herramientas**: `integration_test`
**Ubicación**: `test/integration/`

## 🛠️ Configuración del Entorno de Testing

### Dependencias en `pubspec.yaml`

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.7
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

### Archivos de Configuración

#### `analysis_options.yaml`
```yaml
analyzer:
  exclude:
    - lib/**/*.g.dart
    - test/**/*.mocks.dart

linter:
  rules:
    - test_types_in_equals
    - avoid_redundant_argument_values
    - avoid_types_as_parameter_names
```

## 📝 Estructura de Tests

### Unit Tests

```
test/
├── unit/
│   ├── core/
│   │   ├── services/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── user/
│   │   └── conductor/
│   └── providers/
```

### Widget Tests

```
test/
├── widget/
│   ├── core/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   │   └── screens/
│   │   ├── user/
│   │   └── conductor/
│   └── ui/
```

### Integration Tests

```
test/
└── integration/
    ├── auth_flow_test.dart
    ├── user_flow_test.dart
    └── conductor_flow_test.dart
```

## 🔧 Tests Unitarios

### Configuración Básica

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generar mocks automáticamente
@GenerateMocks([UserRepository, ApiService])
void main() {
  // Tests aquí
}
```

### Patrón AAA (Arrange, Act, Assert)

```dart
void main() {
  group('UserService', () {
    late UserService userService;
    late MockUserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
      userService = UserService(mockRepository);
    });

    test('should return user when getUser is called', () async {
      // Arrange
      const userId = '123';
      const expectedUser = User(id: userId, name: 'John Doe');
      when(mockRepository.getUser(userId))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await userService.getUser(userId);

      // Assert
      expect(result, expectedUser);
      verify(mockRepository.getUser(userId)).called(1);
    });
  });
}
```

### Testing de Providers

```dart
void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('should update login status', () {
      // Arrange
      expect(authProvider.isLoggedIn, false);

      // Act
      authProvider.login('user@example.com', 'password');

      // Assert
      expect(authProvider.isLoggedIn, true);
    });

    test('should notify listeners when login status changes', () {
      // Arrange
      bool notified = false;
      authProvider.addListener(() => notified = true);

      // Act
      authProvider.login('user@example.com', 'password');

      // Assert
      expect(notified, true);
    });
  });
}
```

### Testing de Use Cases

```dart
void main() {
  group('LoginUseCase', () {
    late LoginUseCase loginUseCase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      loginUseCase = LoginUseCase(mockAuthRepository);
    });

    test('should return success when credentials are valid', () async {
      // Arrange
      const loginParams = LoginParams(
        email: 'user@example.com',
        password: 'password123'
      );
      const expectedResult = Right(AuthUser(id: '123', email: 'user@example.com'));

      when(mockAuthRepository.login(loginParams))
          .thenAnswer((_) async => expectedResult);

      // Act
      final result = await loginUseCase(loginParams);

      // Assert
      expect(result, expectedResult);
      verify(mockAuthRepository.login(loginParams)).called(1);
    });

    test('should return failure when credentials are invalid', () async {
      // Arrange
      const loginParams = LoginParams(
        email: 'user@example.com',
        password: 'wrongpassword'
      );
      const expectedResult = Left(AuthFailure.invalidCredentials());

      when(mockAuthRepository.login(loginParams))
          .thenAnswer((_) async => expectedResult);

      // Act
      final result = await loginUseCase(loginParams);

      // Assert
      expect(result, expectedResult);
      expect(result.isLeft(), true);
    });
  });
}
```

## 🎨 Tests de Widgets

### Configuración Básica

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsNWidgets(2)); // email y password
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });
  });
}
```

### Testing de Interacciones

```dart
testWidgets('should call login when form is submitted',
    (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => mockAuthProvider,
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  // Act
  await tester.enterText(
    find.byKey(const Key('email_field')),
    'user@example.com'
  );
  await tester.enterText(
    find.byKey(const Key('password_field')),
    'password123'
  );
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pump();

  // Assert
  verify(mockAuthProvider.login('user@example.com', 'password123')).called(1);
});
```

### Testing de Estados

```dart
testWidgets('should show loading indicator during login',
    (WidgetTester tester) async {
  // Arrange
  when(mockAuthProvider.isLoading).thenReturn(true);

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsNothing);
});
```

### Testing de Navegación

```dart
testWidgets('should navigate to home on successful login',
    (WidgetTester tester) async {
  // Arrange
  when(mockAuthProvider.login(any, any))
      .thenAnswer((_) async => Future.value());

  await tester.pumpWidget(
    MaterialApp(
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
      },
    ),
  );

  // Act
  await tester.enterText(find.byType(TextField).first, 'user@example.com');
  await tester.enterText(find.byType(TextField).last, 'password123');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(HomeScreen), findsOneWidget);
  expect(find.byType(LoginScreen), findsNothing);
});
```

## 🔗 Tests de Integración

### Configuración

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete user registration flow', (WidgetTester tester) async {
      // Test completo aquí
    });
  });
}
```

### Flujo Completo de Autenticación

```dart
testWidgets('complete authentication flow', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(const PingGoApp());

  // Act & Assert - Splash Screen
  await tester.pumpAndSettle();
  expect(find.byType(SplashScreen), findsOneWidget);

  // Act & Assert - Onboarding
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
  expect(find.byType(OnboardingScreen), findsOneWidget);

  // Act & Assert - Registration
  await tester.tap(find.text('Registrarse'));
  await tester.pumpAndSettle();
  expect(find.byType(RegisterScreen), findsOneWidget);

  // Fill registration form
  await tester.enterText(
    find.byKey(const Key('name_field')),
    'John Doe'
  );
  await tester.enterText(
    find.byKey(const Key('email_field')),
    'john.doe@example.com'
  );
  await tester.enterText(
    find.byKey(const Key('phone_field')),
    '+1234567890'
  );

  // Submit registration
  await tester.tap(find.byKey(const Key('register_button')));
  await tester.pumpAndSettle();

  // Assert - Email verification
  expect(find.byType(EmailVerificationScreen), findsOneWidget);
});
```

## 🛠️ Herramientas y Utilidades

### Generación de Mocks

```bash
# Generar mocks para tests
flutter pub run build_runner build

# Observar cambios y regenerar automáticamente
flutter pub run build_runner watch
```

### Cobertura de Código

```bash
# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Tests Específicos

```bash
# Ejecutar solo unit tests
flutter test test/unit/

# Ejecutar solo widget tests
flutter test test/widget/

# Ejecutar solo integration tests
flutter test integration_test/

# Ejecutar test específico
flutter test test/unit/auth/login_test.dart

# Ejecutar tests con patrón
flutter test --plain-name "login"
```

## 📊 Métricas de Calidad

### Cobertura Mínima Requerida
- **Unit Tests**: 80% cobertura mínima
- **Widget Tests**: 70% cobertura mínima
- **Integration Tests**: 50% cobertura mínima
- **Total**: 75% cobertura general

### Métricas de Código
- **Maintainability Index**: > 70
- **Cyclomatic Complexity**: < 10 por método
- **Lines of Code**: < 300 por archivo

## 🔄 CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.0'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test --coverage

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

## 🐛 Debugging de Tests

### Tests que Fallan

```dart
// Test que verifica manejo de errores
test('should handle network errors gracefully', () async {
  // Arrange
  when(mockRepository.getUser(any))
      .thenThrow(NetworkException('Connection failed'));

  // Act
  final result = await userService.getUser('123');

  // Assert
  expect(result.isLeft(), true);
  expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
});
```

### Tests Asíncronos

```dart
test('should complete async operation within timeout', () async {
  // Arrange
  final completer = Completer<void>();

  // Act
  userService.performAsyncOperation().then((_) => completer.complete());

  // Assert
  await completer.future.timeout(const Duration(seconds: 5));
  expect(completer.isCompleted, true);
});
```

## 📋 Mejores Prácticas

### Estructura de Tests
1. **Given-When-Then**: Usar comentarios para separar fases
2. **One Assertion per Test**: Cada test verifica una cosa específica
3. **Descriptive Names**: Nombres descriptivos que explican qué se testea
4. **Independent Tests**: Tests que no dependen del estado de otros

### Mocks y Stubs
1. **Minimal Mocks**: Mockear solo lo necesario
2. **Realistic Data**: Usar datos realistas en tests
3. **Verify Interactions**: Verificar llamadas a métodos cuando es relevante

### Mantenimiento
1. **Regular Updates**: Actualizar tests cuando cambia el código
2. **Remove Obsolete Tests**: Eliminar tests que ya no son relevantes
3. **Performance**: Tests que se ejecutan rápidamente

## 🚨 Casos Especiales

### Testing de APIs
```dart
test('should handle API rate limiting', () async {
  // Arrange
  when(mockApiService.getData())
      .thenThrow(RateLimitException());

  // Act & Assert
  expect(
    () => dataService.fetchData(),
    throwsA(isA<RateLimitException>())
  );
});
```

### Testing de UI Compleja
```dart
testWidgets('should handle screen rotation', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(const MyApp());

  // Act - Simulate rotation
  await tester.binding.setSurfaceSize(const Size(800, 600));
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### Testing de Animaciones
```dart
testWidgets('should animate button press', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(home: AnimatedButton())
  );

  // Act
  await tester.tap(find.byType(AnimatedButton));
  await tester.pump(); // Start animation
  await tester.pump(const Duration(milliseconds: 500)); // Mid animation

  // Assert
  // Verify animation state
});
```

Esta guía proporciona una base sólida para implementar testing efectivo en PingGo, asegurando que el código sea confiable, mantenible y de alta calidad.

---

*Última actualización: $(date '+%Y-%m-%d')*