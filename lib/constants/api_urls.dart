class ApiUrls {
  static const String domain = 'https://services.heterohcl.com';
  static const String baseUrl = '$domain/dfs-icon/api';

  static const String sendOtp = '$baseUrl/auth/send_otp';
  static const String verifyOtp = '$baseUrl/auth/verify_otp';
  static const String refreshToken = '$baseUrl/auth/refresh_token';
  static const String logout = '$baseUrl/auth/logout';
}
