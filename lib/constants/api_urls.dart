class ApiUrls {
  static const String domain = 'https://services.heterohcl.com';
  static const String baseUrl = '$domain/dfs-icon/api';

  static const String sendOtp = '$baseUrl/auth/send_otp';
  static const String verifyOtp = '$baseUrl/auth/verify_otp';
  static const String refreshToken = '$baseUrl/auth/refresh_token';
  static const String logout = '$baseUrl/auth/logout';

  static const String uploadProfilePicture = '$baseUrl/utility/upload_profile_picture';
  static const String getSummits = '$baseUrl/utility/get_summits';
  static const String submitAbstract = '$baseUrl/speaker/submit_abstract';
  static const String myAbstracts = '$baseUrl/speaker/my_abstracts';
  static const String abstractDetails = '$baseUrl/speaker/abstract_details';
  static const String resubmitAbstract = '$baseUrl/speaker/resubmit_abstract';
  static const String getSponsors = '$baseUrl/utility/get_sponsors';
}
