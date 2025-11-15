import 'user.dart';

/// Entidad de Dominio: AuthSession
/// 
/// Representa una sesión de autenticación activa.
/// Inmutable y sin dependencias de frameworks.
class AuthSession {
  final User user;
  final String? token;
  final DateTime? tokenExpiresAt;
  final DateTime loginAt;

  const AuthSession({
    required this.user,
    this.token,
    this.tokenExpiresAt,
    required this.loginAt,
  });

  /// Validación: Sesión tiene token válido
  bool get hasToken => token != null && token!.isNotEmpty;

  /// Validación: Token no ha expirado
  bool get isTokenValid {
    if (!hasToken) return false;
    if (tokenExpiresAt == null) return true; // Sin expiración definida
    return DateTime.now().isBefore(tokenExpiresAt!);
  }

  /// Validación: Sesión es válida
  bool get isValid => hasToken && isTokenValid;

  /// Tiempo restante hasta expiración (null si no expira)
  Duration? get timeUntilExpiration {
    if (tokenExpiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(tokenExpiresAt!)) return Duration.zero;
    return tokenExpiresAt!.difference(now);
  }

  AuthSession copyWith({
    User? user,
    String? token,
    DateTime? tokenExpiresAt,
    DateTime? loginAt,
  }) {
    return AuthSession(
      user: user ?? this.user,
      token: token ?? this.token,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      loginAt: loginAt ?? this.loginAt,
    );
  }

  @override
  String toString() {
    return 'AuthSession(user: ${user.nombreCompleto}, isValid: $isValid)';
  }
}
