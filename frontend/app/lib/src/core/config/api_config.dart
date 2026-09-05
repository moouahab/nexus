abstract final class ApiConfig {
  static const identityUrl = 'http://127.0.0.1:8182';
}

abstract final class ApiAuthEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const me = '/auth/me';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
}
