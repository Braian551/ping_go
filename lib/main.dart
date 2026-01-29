import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping_go/src/routes/app_router.dart';
import 'package:ping_go/src/providers/database_provider.dart';
import 'package:ping_go/src/features/conductor/providers/conductor_profile_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es_ES', null);

  // Inicializar Service Locator (Inyección de Dependencias)
  // Esto configura todos los datasources, repositories y use cases

  runApp(
    MultiProvider(
      providers: [
        // Proveedor de Base de Datos (legacy)
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        
        

        // ========== PROVEEDORES LEGACY (por deprecar gradualmente) ==========
        
        // Proveedores de Conductor (legacy - funcionalidad migrada a Microservicio de Conductor)
        ChangeNotifierProvider(create: (_) => ConductorProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool enableDatabaseInit;

  const MyApp({super.key, this.enableDatabaseInit = true});

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(
      context,
      listen: false,
    );

    // Inicializar la base de datos en background cuando se carga la app
    if (enableDatabaseInit) {
      // No bloqueamos la UI: inicializamos en background y dejamos que el RouterScreen se muestre.
      Future.microtask(() => databaseProvider.initializeDatabase());
    }

    return MaterialApp(
      title: 'Ping-Go',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: Colors.black, // Fondo negro para toda la app
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      navigatorObservers: [RouteLogger()],
      initialRoute: '/',
    );
  }
}

// Observador de Navegación simple para registrar cambios de ruta en modo debug
class RouteLogger extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    try {
      print('Ruta empujada: ${route.settings.name} <- desde ${previousRoute?.settings.name}');
    } catch (_) {}
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    try {
      print('Ruta retirada: ${route.settings.name} -> volver a ${previousRoute?.settings.name}');
    } catch (_) {}
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    try {
      print('Ruta reemplazada: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
    } catch (_) {}
  }
}
