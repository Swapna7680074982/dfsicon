class ApiUrls {
  static const String domain = 'https://services.heterohcl.com';
  static const String baseUrl = '$domain/dfs-icon/api';

  static const String sendOtp = '$baseUrl/auth/send_otp';
  static const String verifyOtp = '$baseUrl/auth/verify_otp';
  static const String loginPassword = '$baseUrl/auth/login_password';
  static const String changePassword = '$baseUrl/auth/change_password';
  static const String deleteAccount = '$baseUrl/auth/delete_account';
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
  static const String getVenueAndHalls = '$baseUrl/utility/get_venue_and_halls';
  static const String getSummitBooths = '$baseUrl/utility/get_summit_booths';
  static const String myQr = '$baseUrl/utility/my_qr';
  static const String venueLayouts = '$baseUrl/utility/venue_layouts';
  static const String getDocuments = '$baseUrl/utility/documents';

  // Gallery Module APIs
  static const String galleryFaces = '$baseUrl/utility/gallery_faces';
  static const String galleryDays = '$baseUrl/utility/gallery_days';
  static const String galleryImages = '$baseUrl/utility/gallery_images';
  static const String galleryMatch = '$baseUrl/utility/gallery_match';

  static const String myWorkshops = '$baseUrl/utility/my_workshops';
  static const String viewWorkshopParticipants = '$baseUrl/utility/view_workshop_participants';
  static const String speakerMyTopics = '$baseUrl/speaker/my_topics';
  static const String speakerTopicDetails = '$baseUrl/speaker/topic_details';
  static const String speakerUpdateTopicDetails = '$baseUrl/speaker/update_topic_details';

  static const String bookmarkSession = '$baseUrl/delegate/bookmark_session';
  static const String unbookmarkSession = '$baseUrl/delegate/unbookmark_session';
  static const String myBookmarks = '$baseUrl/delegate/my_bookmarks';
  static const String summitStats = '$baseUrl/utility/summit_stats';
  static const String invitedSpeakers = '$baseUrl/utility/invited_speakers';
  static const String myProfile = '$baseUrl/utility/my_profile';
  static const String updateProfile = '$baseUrl/utility/update_profile';
  static const String updatePrivacySettings = '$baseUrl/utility/update_privacy_settings';
  static const String myNotifications = '$baseUrl/utility/my_notifications';
  static const String markNotificationRead = '$baseUrl/utility/mark_notification_read';
  static const String registerToken = '$baseUrl/auth/register_token';

  // Networking Module APIs
  static const String sessionParticipants = '$baseUrl/networking/session_participants';
  static const String sendRequest = '$baseUrl/networking/send_request';
  static const String pendingRequests = '$baseUrl/networking/pending_requests';
  static const String respondRequest = '$baseUrl/networking/respond_request';
  static const String disconnect = '$baseUrl/networking/disconnect';
  static const String cancelRequest = '$baseUrl/networking/cancel_request';
  static const String myConnections = '$baseUrl/networking/my_connections';
  static const String sendMessage = '$baseUrl/networking/send_message';
  static const String messages = '$baseUrl/networking/messages';
  static const String markRead = '$baseUrl/networking/mark_read';
  static const String unreadCount = '$baseUrl/networking/unread_count';
  static const String createGroup = '$baseUrl/networking/create_group';
  static const String groupDetails = '$baseUrl/networking/group_details';
  static const String addMembers = '$baseUrl/networking/add_members';
  static const String removeMember = '$baseUrl/networking/remove_member';
  static const String leaveGroup = '$baseUrl/networking/leave_group';
  static const String conversations = '$baseUrl/networking/conversations';

  // Q&A Module APIs
  static const String qaQuestions = '$baseUrl/qa/questions';
  static const String qaPostQuestion = '$baseUrl/qa/post_question';
  static const String qaPostReply = '$baseUrl/qa/post_reply';
  static const String qaQuestionDetail = '$baseUrl/qa/question_detail';
  static const String qaDeleteQuestion = '$baseUrl/qa/delete_question';
  static const String qaDeleteReply = '$baseUrl/qa/delete_reply';
  static const String qaMyQuestions = '$baseUrl/qa/my_questions';
  static const String qaSessionThread = '$baseUrl/qa/session_thread';

  // Admin Module APIs
  static const String adminDashboardStats = '$baseUrl/admin/dashboard_stats';
  static const String adminAllSpeakers = '$baseUrl/admin/all_speakers';
  static const String adminSpeakerDetails = '$baseUrl/admin/speaker_details';
  static const String adminAllDelegates = '$baseUrl/admin/all_delegates';
  static const String adminDelegateDetails = '$baseUrl/admin/delegate_details';
  static const String adminAllTopics = '$baseUrl/admin/all_topics';
  static const String adminTopicDetails = '$baseUrl/admin/topic_details';
  static const String adminTopicBookmarks = '$baseUrl/admin/topic_bookmarks';
  static const String adminAllWorkshops = '$baseUrl/admin/all_workshops';
  static const String adminWorkshopParticipants = '$baseUrl/admin/workshop_participants';
  static const String adminAllSponsors = '$baseUrl/admin/all_sponsors';
  static const String adminSponsorDetails = '$baseUrl/admin/sponsor_details';
  static const String adminAllSponsorCategories = '$baseUrl/admin/all_sponsor_categories';
  static const String adminAllBooths = '$baseUrl/admin/all_booths';
  static const String adminAllSponsorBooths = '$baseUrl/admin/all_booths';
  static const String adminBoothDetails = '$baseUrl/admin/booth_details';
  static const String adminAllSlots = '$baseUrl/admin/all_slots';
  static const String adminSlotDetails = '$baseUrl/admin/slot_details';
  static const String adminSponsorBoothStats = '$baseUrl/admin/sponsor_booth_stats';
  static const String adminSponsorFootfallParticipants = '$baseUrl/admin/sponsor_footfall_participants';
  static const String adminFootfallOverview = '$baseUrl/admin/footfall_overview';
  static const String adminVisitedAllBoothsParticipantsList = '$baseUrl/admin/visited_all_booths_participants_list';

  // Exhibitor Module APIs
  static const String exhibitorCounts = '$baseUrl/exhibitor/counts';
  static const String exhibitorParticipants = '$baseUrl/exhibitor/participants';
  static const String exhibitorScan = '$baseUrl/exhibitor/scan';
}



