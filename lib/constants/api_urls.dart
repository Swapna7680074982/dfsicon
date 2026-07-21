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
  static const String getConfirmedSessions = '$baseUrl/delegate/confirmed_sessions';
  static const String myConfirmedSessions = '$baseUrl/speaker/my_confirmed_sessions';
  static const String getVenueAndHalls = '$baseUrl/utility/get_venue_and_halls';
  static const String getSummitBooths = '$baseUrl/utility/get_summit_booths';

  static const String myWorkshops = '$baseUrl/utility/my_workshops';
  static const String viewWorkshopParticipants = '$baseUrl/utility/view_workshop_participants';
  static const String speakerMyTopics = '$baseUrl/speaker/my_topics';
  static const String speakerTopicDetails = '$baseUrl/speaker/topic_details';
  static const String speakerUpdateTopicDetails = '$baseUrl/speaker/update_topic_details';

  static const String bookmarkSession = '$baseUrl/delegate/bookmark_session';
  static const String unbookmarkSession = '$baseUrl/delegate/unbookmark_session';
  static const String myBookmarks = '$baseUrl/delegate/my_bookmarks';
  static const String viewSessionParticipants = '$baseUrl/utility/view_session_participants';
  static const String summitStats = '$baseUrl/utility/summit_stats';
  static const String invitedSpeakers = '$baseUrl/utility/invited_speakers';
  static const String myProfile = '$baseUrl/utility/my_profile';
  static const String updateProfile = '$baseUrl/utility/update_profile';
  static const String updatePrivacySettings = '$baseUrl/utility/update_privacy_settings';
}
