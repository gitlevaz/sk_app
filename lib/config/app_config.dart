// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = "https://sahakaru.com/api";

  static const String login = "$baseUrl/mobilelogin";

 static const String imgpath = "https://sahakaru.com//assets/images/user/profile/";
 static const String dashboard = "$baseUrl/dashboard";
 static const String fetchMembers = "$baseUrl/members";
 static const String checkInterestStatus = "$baseUrl/check-interest";
 static const String viewContact = "$baseUrl/viewContact";
 static const String viewContact2 = "$baseUrl/viewContact2";
 static const String interestLimit = "$baseUrl/interest-limit";
  static const String expressInterest = "$baseUrl/express-interest";

    // static const String hideInterest = "$baseUrl/mobilelogin";
  static const String hideInterest = "$baseUrl/hide-interest";
  static const String foundInterests = "$baseUrl/found-interests";
  static const String requestInterests = "$baseUrl/request-interests";
  static const String purchaseHistory = "$baseUrl/purchase-history";

  static const String fetchFoundInterest = "$baseUrl/found-interests";  
  static const String acceptInterest = "$baseUrl/accepted-interest";  // ✅ new
  static const String rejectInterest = "$baseUrl/reject-interest";    // ✅ new

  static const String sentInterests = "$baseUrl/sent-interests";
  static const String cancelInterest = "$baseUrl/cancel-interest";

  static const String hiddenUsers = "$baseUrl/hiddenusers";

  static const String fetchMessageUsers = "$baseUrl/mzgusers";  
  static const String fetchmessages = "$baseUrl/messages";  
  static const String sendInterest = "$baseUrl/send-message";  
  static const String updateProfile = "$baseUrl/update-profile";  
  static const String packages = "$baseUrl/packages";  
  // static const String contact = "$baseUrl/contact";  


}