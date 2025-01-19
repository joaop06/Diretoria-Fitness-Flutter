import 'api.service.dart';

class EmailService {
  final ApiService _apiService = ApiService();

  Future resendVerificationCode(int userId) async {
    try {
      return await _apiService
          .post("/email/resend-verification-code?userId=$userId");
    } catch (e) {
      rethrow;
    }
  }
}
