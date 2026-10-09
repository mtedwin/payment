// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'hello';

  @override
  String get welcomeMessage => 'Welcome Back';

  @override
  String get counterText => 'You have pushed the button this many times:';

  @override
  String get email => 'email';

  @override
  String get password => 'password';

  @override
  String get login => 'login';
}
