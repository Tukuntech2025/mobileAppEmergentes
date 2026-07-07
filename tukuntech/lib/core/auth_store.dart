class AuthStore {
  static String? token; // accessToken
  static String? refreshToken;
  
  static void clear() {
    token = null;
    refreshToken = null;
  }
}
