import 'package:mysql1/mysql1.dart';
import '../../core/constants/app_constants.dart';

class MySQLConnection {
  static final MySQLConnection _instance = MySQLConnection._internal();
  MySqlConnection? _connection;
  
  factory MySQLConnection() {
    return _instance;
  }
  
  MySQLConnection._internal();
  
  // Getter para verificar si la conexión está disponible
  bool get isConnected => _connection != null;
  
  Future<void> connect() async {
    try {
      final settings = ConnectionSettings(
        host: AppConstants.databaseHost,
        port: int.tryParse(AppConstants.databasePort) ?? 3306,
        user: AppConstants.databaseUser,
        password: AppConstants.databasePassword,
        db: AppConstants.databaseName, // Nombre de tu base de datos
        timeout: Duration(seconds: 10),
      );
      
      _connection = await MySqlConnection.connect(settings);
      print('Conexión a MySQL establecida correctamente');
    } catch (e) {
      print('Error al conectar con MySQL: $e');
      _connection = null;
      rethrow;
    }
  }
  
  Future<MySqlConnection> get connection async {
    try {
      if (_connection == null) {
        await connect();
      }
      if (_connection == null) {
        throw Exception('No se pudo establecer conexión con la base de datos');
      }
      return _connection!;
    } catch (e) {
      print('Error en conexión: $e');
      rethrow;
    }
  }
  
  Future<void> close() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        print('Conexión a MySQL cerrada');
      }
    } catch (e) {
      print('Error al cerrar conexión: $e');
    }
  }
  
  // Método para ejecutar consultas
  Future<Results> query(String sql, [List<dynamic>? values]) async {
    try {
      final conn = await connection;
      return await conn.query(sql, values);
    } catch (e) {
      print('Error ejecutando consulta: $e');
      rethrow;
    }
  }
  
  // Método para ejecutar inserciones, updates, deletes
  Future<void> execute(String sql, [List<dynamic>? values]) async {
    try {
      final conn = await connection;
      await conn.query(sql, values);
    } catch (e) {
      print('Error ejecutando comando: $e');
      rethrow;
    }
  }
}