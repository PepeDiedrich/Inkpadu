import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:appwrite/enums.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthController extends Mock implements AuthController {}

void registerAuthFallbackValues() {
  registerFallbackValue(OAuthProvider.github);
  registerFallbackValue(<String>[]);
}
