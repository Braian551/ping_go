# Troubleshooting - PingGo App

## 🔧 Solución de Problemas Comunes

Esta guía proporciona soluciones para los problemas más comunes que pueden surgir durante el desarrollo, testing y despliegue de la aplicación PingGo.

## 🚀 Problemas de Configuración y Setup

### Flutter SDK no encontrado

**Síntomas:**
- Error: `flutter command not found`
- VS Code no reconoce comandos de Flutter

**Soluciones:**

1. **Verificar instalación de Flutter:**
   ```bash
   flutter --version
   ```

2. **Agregar Flutter al PATH:**
   ```bash
   # Windows
   setx PATH "%PATH%;C:\flutter\bin"

   # macOS/Linux
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. **Reiniciar terminal/VS Code**

### Dependencias no instaladas

**Síntomas:**
- Error: `Target of URI doesn't exist`
- Imports marcados en rojo

**Soluciones:**

```bash
# Limpiar cache y reinstalar dependencias
flutter clean
flutter pub get

# Si persiste, eliminar pubspec.lock y reinstalar
rm pubspec.lock
flutter pub get
```

### Problemas con Android SDK

**Síntomas:**
- Error al compilar para Android
- `Android SDK not found`

**Soluciones:**

1. **Instalar Android Studio**
2. **Configurar ANDROID_HOME:**
   ```bash
   # Windows
   setx ANDROID_HOME "C:\Users\[USER]\AppData\Local\Android\Sdk"

   # macOS
   export ANDROID_HOME=$HOME/Library/Android/sdk
   ```
3. **Aceptar licencias:**
   ```bash
   flutter doctor --android-licenses
   ```

## 🏗️ Problemas de Build y Compilación

### Error de compilación en iOS

**Síntomas:**
- Build falla en iOS
- Errores de CocoaPods

**Soluciones:**

```bash
# Limpiar pods y reinstalar
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter build ios
```

### Problemas con Gradle (Android)

**Síntomas:**
- Build lento o fallido
- Errores de Gradle

**Soluciones:**

```bash
# Limpiar Gradle cache
cd android
./gradlew clean
./gradlew build --no-daemon

# O usar Flutter
flutter clean
flutter build apk --debug
```

### Error de versión de SDK

**Síntomas:**
- `The current Dart SDK version is X.X.X, but pubspec.yaml requires Y.Y.Y`

**Soluciones:**

1. **Actualizar Flutter:**
   ```bash
   flutter upgrade
   ```

2. **Cambiar versión en pubspec.yaml:**
   ```yaml
   environment:
     sdk: '>=3.8.0 <4.0.0'  # Ajustar según necesidad
   ```

## 🔄 Problemas de Estado y Providers

### Provider no actualiza UI

**Síntomas:**
- Cambios en provider no se reflejan en UI
- Widgets no se reconstruyen

**Soluciones:**

1. **Verificar ChangeNotifier:**
   ```dart
   class MyProvider extends ChangeNotifier {
     void updateData() {
       _data = newData;
       notifyListeners(); // ← Asegurarse de llamar esto
     }
   }
   ```

2. **Usar Consumer correctamente:**
   ```dart
   Consumer<MyProvider>(
     builder: (context, provider, child) {
       return Text(provider.data); // ← Acceder a datos actualizados
     },
   )
   ```

### Memory leaks con Providers

**Síntomas:**
- Aplicación consume memoria excesiva
- Performance degrade con el tiempo

**Soluciones:**

1. **Dispose listeners:**
   ```dart
   class MyWidget extends StatefulWidget {
     @override
     _MyWidgetState createState() => _MyWidgetState();
   }

   class _MyWidgetState extends State<MyWidget> {
     @override
     void dispose() {
       // Limpiar listeners aquí
       super.dispose();
     }
   }
   ```

2. **Usar Provider con cuidado:**
   ```dart
   // ❌ Mal - Provider global para todo
   ChangeNotifierProvider(create: (_) => GlobalProvider())

   // ✅ Bien - Providers específicos por feature
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => AuthProvider()),
       ChangeNotifierProvider(create: (_) => UserProvider()),
     ],
   )
   ```

## 🗺️ Problemas con Mapas y Geolocalización

### Mapa no se carga

**Síntomas:**
- Mapa aparece en blanco
- Errores de tiles de mapa

**Soluciones:**

1. **Verificar API keys:**
   ```dart
   // En env_config.dart
   const mapApiKey = 'YOUR_API_KEY_HERE';
   ```

2. **Permisos de ubicación:**
   ```xml
   <!-- AndroidManifest.xml -->
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

3. **Configuración de flutter_map:**
   ```dart
   FlutterMap(
     options: MapOptions(
       center: LatLng(0, 0), // ← Verificar coordenadas válidas
       zoom: 13.0,
     ),
     layers: [
       TileLayerOptions(
         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
         subdomains: ['a', 'b', 'c'],
       ),
     ],
   )
   ```

### Geolocalización no funciona

**Síntomas:**
- No obtiene ubicación actual
- Errores de permisos

**Soluciones:**

```dart
// Verificar permisos antes de usar
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}

if (permission == LocationPermission.deniedForever) {
  // Manejar caso donde usuario negó permanentemente
  return;
}

// Obtener ubicación
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high
);
```

## 🔐 Problemas de Autenticación

### Login falla

**Síntomas:**
- Credenciales correctas pero login falla
- Errores de red durante autenticación

**Soluciones:**

1. **Verificar endpoint del backend:**
   ```dart
   // En config
   const baseUrl = 'https://api.pinggo.com';
   ```

2. **Debug de request:**
   ```dart
   try {
     final response = await http.post(
       Uri.parse('$baseUrl/auth/login'),
       body: {
         'email': email,
         'password': password,
       },
     );

     print('Status: ${response.statusCode}');
     print('Body: ${response.body}');
   } catch (e) {
     print('Error: $e');
   }
   ```

3. **Verificar formato de datos:**
   ```dart
   // Asegurarse de enviar datos correctos
   final loginData = {
     'email': email.trim(),
     'password': password,
     'device_token': await getDeviceToken(),
   };
   ```

### Token expirado

**Síntomas:**
- Usuario logueado pero requests fallan con 401

**Soluciones:**

```dart
class ApiService {
  Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'auth_token');
    final expiry = await _storage.read(key: 'token_expiry');

    if (token != null && expiry != null) {
      final expiryDate = DateTime.parse(expiry);
      if (DateTime.now().isBefore(expiryDate)) {
        return token;
      }
    }

    // Token expirado, refrescar
    return await _refreshToken();
  }
}
```

## 💾 Problemas de Base de Datos

### Error de conexión MySQL

**Síntomas:**
- `Connection refused`
- `Access denied for user`

**Soluciones:**

1. **Verificar credenciales:**
   ```php
   // config/database.php
   $host = 'localhost';
   $user = 'pinggo_user';
   $pass = 'secure_password';
   $db = 'pinggo_db';
   ```

2. **Verificar puerto y host:**
   ```bash
   # Test conexión
   mysql -h localhost -P 3306 -u pinggo_user -p pinggo_db
   ```

3. **Firewall y bind-address:**
   ```ini
   # my.cnf
   [mysqld]
   bind-address = 0.0.0.0
   port = 3306
   ```

### SQLite local no funciona

**Síntomas:**
- Datos no persisten
- Error al crear tablas

**Soluciones:**

```dart
// Verificar path de base de datos
final databasesPath = await getDatabasesPath();
final path = join(databasesPath, 'pinggo.db');

// Crear tablas con versiones
await openDatabase(
  path,
  version: 1,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT
      )
    ''');
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    // Manejar migraciones
  },
);
```

## 🌐 Problemas de Red y APIs

### Timeout en requests

**Síntomas:**
- Requests tardan mucho o fallan
- `Connection timeout`

**Soluciones:**

```dart
// Configurar timeouts apropiados
final client = http.Client();
try {
  final response = await client.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  ).timeout(const Duration(seconds: 30));
} on TimeoutException catch (_) {
  // Manejar timeout
} finally {
  client.close();
}
```

### Error de CORS

**Síntomas:**
- Requests funcionan en Postman pero fallan en app
- Error: `CORS policy`

**Soluciones:**

1. **Backend - Agregar headers CORS:**
   ```php
   header('Access-Control-Allow-Origin: *');
   header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
   header('Access-Control-Allow-Headers: Content-Type, Authorization');
   ```

2. **Flutter - Usar proxy en desarrollo:**
   ```yaml
   # pubspec.yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/
   ```

### Error de certificado SSL

**Síntomas:**
- `CERTIFICATE_VERIFY_FAILED`
- Funciona en desarrollo pero falla en producción

**Soluciones:**

```dart
// Para desarrollo - ignorar certificados
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// Usar solo en desarrollo
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}
```

## 📱 Problemas de UI y Widgets

### Widget no se reconstruye

**Síntomas:**
- UI no refleja cambios de estado
- setState() no funciona

**Soluciones:**

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++; // ← Esto dispara reconstrucción
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _incrementCounter,
      child: Text('Count: $_counter'),
    );
  }
}
```

### Performance issues con listas

**Síntomas:**
- ListView laggea con muchos items
- Scroll no fluido

**Soluciones:**

```dart
// Usar ListView.builder para listas grandes
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
      // ... otros widgets
    );
  },
)

// Usar const constructors cuando sea posible
const Text('Static Text') // ✅ Bien
Text('Dynamic Text')      // ❌ Mal si no cambia
```

### Problemas de layout

**Síntomas:**
- Widgets se salen de pantalla
- Overflow errors

**Soluciones:**

```dart
// Usar Expanded y Flexible
Row(
  children: [
    Expanded( // ← Toma espacio disponible
      child: TextField(),
    ),
    IconButton(icon: Icon(Icons.search)),
  ],
)

// Usar SingleChildScrollView para contenido largo
SingleChildScrollView(
  child: Column(
    children: [
      // Contenido largo aquí
    ],
  ),
)
```

## 🧪 Problemas de Testing

### Tests fallan aleatoriamente

**Síntomas:**
- Tests pasan/fallan inconsistentemente
- Errores de timing

**Soluciones:**

```dart
testWidgets('async test', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // Esperar a que todas las animaciones terminen
  await tester.pumpAndSettle();

  // Verificar estado final
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Mocks no funcionan

**Síntomas:**
- `MockitoError: No method stub was called`
- Tests fallan por llamadas no mockeadas

**Soluciones:**

```dart
@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
  });

  test('should return user', () async {
    // Arrange - Configurar comportamiento esperado
    when(mockRepository.getUser('123'))
        .thenAnswer((_) async => User(id: '123', name: 'John'));

    // Act
    final result = await userService.getUser('123');

    // Assert
    expect(result.name, 'John');
  });
}
```

## 🚀 Problemas de Despliegue

### Build falla en CI/CD

**Síntomas:**
- Build local funciona, falla en pipeline
- Errores de dependencias

**Soluciones:**

1. **Verificar versiones en CI:**
   ```yaml
   # .github/workflows/build.yml
   - uses: subosito/flutter-action@v2
     with:
       flutter-version: '3.8.0'  # ← Misma versión que local
   ```

2. **Cache de dependencias:**
   ```yaml
   - name: Cache Flutter dependencies
     uses: actions/cache@v3
     with:
       path: |
         ~/.pub-cache
       key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.yaml') }}
   ```

### App size demasiado grande

**Síntomas:**
- APK/IPA > 50MB
- Upload lento

**Soluciones:**

```bash
# Build con split por ABI (Android)
flutter build apk --split-per-abi

# Build app bundle (Android)
flutter build appbundle

# Build con tree shaking
flutter build ios --release --tree-shake-icons
```

## 📊 Monitoreo y Logs

### Ver logs de la aplicación

```bash
# Ver logs en tiempo real
flutter logs

# Ver logs de Android
adb logcat

# Ver logs de iOS
flutter logs -d <device_id>
```

### Debug de performance

```dart
// Agregar performance overlay
void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          MyApp(),
          Positioned(
            top: 0,
            right: 0,
            child: PerformanceOverlay.allEnabled(), // ← Debug overlay
          ),
        ],
      ),
    ),
  );
}
```

## 🆘 Cuando todo falla

### Reset completo del proyecto

```bash
# Limpiar todo
flutter clean
rm -rf .flutter-plugins .flutter-plugins-dependencies
rm -rf ios/Pods ios/Podfile.lock android/.gradle
rm pubspec.lock

# Reinstalar todo
flutter pub get
cd ios && pod install && cd ..
flutter build apk --debug
```

### Verificar estado del proyecto

```bash
# Verificar Flutter
flutter doctor -v

# Verificar dependencias
flutter pub outdated

# Verificar tamaño del proyecto
du -sh .
```

### Buscar ayuda adicional

1. **Documentación oficial de Flutter:** https://flutter.dev/docs
2. **Stack Overflow:** Buscar con tags `flutter`, `dart`
3. **GitHub Issues:** Revisar issues similares en repositorios
4. **Comunidad:** Discord de Flutter, Reddit r/FlutterDev

Recuerda que la mayoría de problemas tienen soluciones documentadas. Si encuentras un problema nuevo, documenta la solución para futuros desarrolladores.

---

*Última actualización: $(date '+%Y-%m-%d')*