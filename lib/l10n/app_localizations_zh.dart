// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '你好';

  @override
  String get welcomeMessage => '歡迎回來';

  @override
  String get counterText => '你已經點了這個按鈕多少次：';

  @override
  String get email => 'email';

  @override
  String get password => 'password';

  @override
  String get login => '登入';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans(): super('zh_Hans');

  @override
  String get appTitle => '你好';

  @override
  String get welcomeMessage => '欢迎回来';

  @override
  String get counterText => '你已经点击了这个按钮多少次：';

  @override
  String get email => 'email';

  @override
  String get password => 'password';

  @override
  String get login => '登入';
}
