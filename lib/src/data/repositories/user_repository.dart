import '../database/mysql_connection.dart';

class UserRepository {
  final MySQLConnection _dbConnection = MySQLConnection();
  
  // Crear usuario
  Future<int> createUser(String email, String password, String name) async {
    try {
      final result = await _dbConnection.query(
        'INSERT INTO users (email, password, name, created_at) VALUES (?, ?, ?, NOW())',
        [email, password, name]
      );
      return result.insertId!;
    } catch (e) {
      print('Error al crear usuario: $e');
      rethrow;
    }
  }
  
  // Obtener usuario por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final results = await _dbConnection.query(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );
      
      if (results.isNotEmpty) {
        final row = results.first;
        return {
          'id': row['id'],
          'email': row['email'],
          'password': row['password'],
          'name': row['name'],
          'created_at': row['created_at']
        };
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      rethrow;
    }
  }
  
  // Verificar credenciales de login
  Future<Map<String, dynamic>?> verifyCredentials(String email, String password) async {
    try {
      final results = await _dbConnection.query(
        'SELECT * FROM users WHERE email = ? AND password = ?',
        [email, password]
      );
      
      if (results.isNotEmpty) {
        final row = results.first;
        return {
          'id': row['id'],
          'email': row['email'],
          'name': row['name'],
          'created_at': row['created_at']
        };
      }
      return null;
    } catch (e) {
      print('Error al verificar credenciales: $e');
      rethrow;
    }
  }
}