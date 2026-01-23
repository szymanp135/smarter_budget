import 'package:hive/hive.dart';
import '../providers/app_settings_provider.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class AppUser {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final AppTheme theme;

  @HiveField(4)
  final AppLanguage language;

  @HiveField(5)
  final AppCurrency? currency;

  @HiveField(6)
  final double? monthlyLimit;

  AppUser({
    required this.userId,
    required this.username,
    required this.password,
    AppTheme? theme,
    AppLanguage? language,
    this.currency,
    this.monthlyLimit,
  }) : theme = theme ?? AppTheme.light,
       language = language ?? AppLanguage.pl;

  AppUser copyWith({
    AppTheme? theme,
    AppLanguage? language,
    AppCurrency? currency,
    double? monthlyLimit,
  }) {
    return AppUser(
      userId: userId,
      username: username,
      password: password,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }
}
