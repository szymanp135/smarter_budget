import 'package:hive/hive.dart';
import '../providers/app_settings_provider.dart';

class AppThemeAdapter extends TypeAdapter<AppTheme> {
  @override
  final int typeId = 10;

  @override
  AppTheme read(BinaryReader reader) => AppTheme.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, AppTheme obj) => writer.writeByte(obj.index);
}

class AppLanguageAdapter extends TypeAdapter<AppLanguage> {
  @override
  final int typeId = 11;

  @override
  AppLanguage read(BinaryReader reader) =>
      AppLanguage.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, AppLanguage obj) =>
      writer.writeByte(obj.index);
}

class AppCurrencyAdapter extends TypeAdapter<AppCurrency> {
  @override
  final int typeId = 12;

  @override
  AppCurrency read(BinaryReader reader) =>
      AppCurrency.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, AppCurrency obj) =>
      writer.writeByte(obj.index);
}
